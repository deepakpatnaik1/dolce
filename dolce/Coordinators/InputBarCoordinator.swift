//
//  InputBarCoordinator.swift
//  Dolce
//
//  Input bar operation orchestration
//
//  ATOMIC RESPONSIBILITY: Coordinate input operations only
//  - Orchestrate file picking flow
//  - Coordinate message sending
//  - Delegate to appropriate services
//  - Zero business logic or direct processing
//

import Foundation
import SwiftUI

@MainActor
class InputBarCoordinator: ObservableObject {
    private let conversationOrchestrator: ConversationOrchestrator
    private let fileDropHandler: FileDropHandler
    private let turnModeCoordinator = TurnModeCoordinator.shared
    private let messageStore: MessageStore
    private let runtimeModelManager = RuntimeModelManager.shared
    
    // New services for height calculation fix
    let debouncedHeightCalculator = DebouncedHeightCalculator()
    let animationCoordinator = AnimationCoordinator()
    
    // Journal mode service
    private let journalModeManager = JournalModeManager()
    
    init(conversationOrchestrator: ConversationOrchestrator, 
         fileDropHandler: FileDropHandler,
         messageStore: MessageStore) {
        self.conversationOrchestrator = conversationOrchestrator
        self.fileDropHandler = fileDropHandler
        self.messageStore = messageStore
    }
    
    // MARK: - Send Message Flow
    
    /// Handle send action - orchestrate message composition and sending
    func handleSendAction(text: String, state: InputBarState) async {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasText = !trimmedText.isEmpty
        let hasFiles = !fileDropHandler.droppedFiles.isEmpty
        
        guard hasText || hasFiles else { return }
        
        // Check for delete command
        if let slashCommand = SlashCommandParser.parseCommand(from: trimmedText) {
            switch slashCommand {
            case .delete:
                // Handle delete command
                let commandText = SlashCommand.extractText(from: trimmedText, command: .delete)
                handleDeleteCommand(commandText)
                
                // Clear input and return (don't send as a message)
                state.clearInput()
                return
            case .journal:
                // Journal is handled in handleTextChange
                break
            }
        }
        
        // Detect persona from message
        var finalText = trimmedText
        var targetPersona: String
        
        if let detected = PersonaDetector.detectPersona(from: trimmedText) {
            // Persona detected - switch to it
            targetPersona = detected.persona
            
            // Always preserve the full message including persona name
            finalText = trimmedText
            
            // Update session
            PersonaSessionManager.shared.setCurrentPersona(targetPersona)
            
            // Switch to appropriate model for this persona
            switchToDefaultModel(for: targetPersona)
        } else {
            // No persona in message - use current session persona
            targetPersona = PersonaSessionManager.shared.getCurrentPersona()
        }
        
        // Compose message with potentially cleaned text
        let messageContent = MessageComposer.compose(
            text: finalText,
            files: fileDropHandler.droppedFiles
        )
        
        // Capture attachments before clearing
        let attachments = fileDropHandler.droppedFiles
        
        // Clear UI state
        state.clearInput()
        fileDropHandler.clearFiles()
        
        // Handle journal mode exit if active
        if state.journalModeState.isInJournalMode {
            // Restore previous persona after sending journal entry
            if let previousPersona = state.journalModeState.previousPersona {
                PersonaSessionManager.shared.setCurrentPersona(previousPersona)
            }
            
            // Clear journal mode state
            state.journalModeState = journalModeManager.createExitedState()
            
            // Restore text alignment to center
            state.textAlignment = .center
        }
        
        // Send message with detected or current persona
        await conversationOrchestrator.sendMessageWithAttachments(
            messageContent,
            attachments: attachments,
            persona: targetPersona
        )
        
        // Handle turn mode
        if TurnManager.shared.isInTurnMode {
            turnModeCoordinator.handleNewMessageInTurnMode(
                messages: messageStore.messages
            )
        }
    }
    
    // MARK: - File Picker Flow
    
    /// Handle file picker action - orchestrate file selection and validation
    func handleFilePickAction() async {
        // Get file URLs from picker
        let urls = await FilePickerService.pickFiles()
        
        // Process each selected file
        for url in urls {
            await processSelectedFile(url)
        }
    }
    
    /// Process a single selected file
    private func processSelectedFile(_ url: URL) async {
        // Validate file
        switch FileValidator.validate(url: url) {
        case .success(let validation):
            // Read file content
            do {
                let content = try await FileReader.readFile(
                    at: url,
                    type: validation.fileType
                )
                
                // Create dropped file
                let droppedFile = DroppedFile(
                    name: validation.fileName,
                    type: validation.fileType,
                    size: validation.fileSize,
                    data: content.data,
                    previewText: content.previewText
                )
                
                // Add to handler
                fileDropHandler.addFile(droppedFile)
                
            } catch {
                // Log error but continue with other files
                // Error reading file - silently continue
            }
            
        case .failure(_):
            break // File validation failed - silently continue
        }
    }
    
    // MARK: - Keyboard Command Handling
    
    /// Handle keyboard commands from input bar
    func handleKeyboardCommand(_ action: KeyboardAction, state: InputBarState) -> KeyPress.Result {
        switch action {
        case .turnNavigateUp:
            turnModeCoordinator.handleKeyboardCommand(.navigateUp, messages: messageStore.messages)
            return .handled
        case .turnNavigateDown:
            turnModeCoordinator.handleKeyboardCommand(.navigateDown, messages: messageStore.messages)
            return .handled
        case .turnModeExit:
            turnModeCoordinator.handleKeyboardCommand(.exitTurnMode, messages: messageStore.messages)
            return .handled
        case .journalModeExit:
            // Validate exit conditions
            guard state.journalModeState.isInJournalMode else { return .ignored }
            guard journalModeManager.canExitJournalMode(text: state.text) else { return .ignored }
            
            Task { @MainActor in
                // Restore original height
                let originalHeight = state.journalModeState.originalHeight
                
                // Animate back to original height using existing services
                HeightAnimationEngine.animateHeightChange(
                    from: state.textHeight,
                    to: originalHeight,
                    animationId: UUID(),
                    coordinator: animationCoordinator
                ) { height in
                    state.textHeight = height
                }
                
                // Restore previous persona if stored
                if let previousPersona = state.journalModeState.previousPersona {
                    PersonaSessionManager.shared.setCurrentPersona(previousPersona)
                }
                
                // Clear journal mode state
                state.journalModeState = journalModeManager.createExitedState()
                
                // Restore text alignment to center
                state.textAlignment = .center
            }
            
            return .handled
        default:
            return .ignored
        }
    }
    
    // MARK: - Persona Detection and Model Switching
    
    /// Handle text changes to detect persona and switch models
    func handleTextChange(_ text: String, state: InputBarState) {
        // Check for slash commands first
        if let command = SlashCommandParser.shouldExecuteCommand(in: text) {
            switch command {
            case .journal:
                // Validate entry
                guard journalModeManager.canEnterJournalMode() else { return }
                
                Task { @MainActor in
                    // Store current state
                    let currentHeight = state.textHeight
                    let currentPersona = PersonaSessionManager.shared.getCurrentPersona()
                    
                    // Cancel any pending height calculations
                    debouncedHeightCalculator.cancelPendingCalculations()
                    
                    // Create journal mode state
                    state.journalModeState = journalModeManager.createEnteringState(
                        originalHeight: currentHeight,
                        previousPersona: currentPersona
                    )
                    
                    // Switch to Eva persona
                    PersonaSessionManager.shared.setCurrentPersona("eva")
                    
                    // Set text alignment to top for journal mode
                    state.textAlignment = .top
                    
                    // Calculate maximum height using existing service
                    let maxHeight = TextMeasurementEngine.calculateMaximumTextHeight()
                    
                    // Clear the /journal command from input
                    state.text = ""
                    
                    // Animate to maximum height using existing services
                    HeightAnimationEngine.animateHeightChange(
                        from: currentHeight,
                        to: maxHeight,
                        animationId: UUID(),
                        coordinator: animationCoordinator
                    ) { height in
                        state.textHeight = height
                    }
                }
            case .delete:
                // Don't execute immediately - wait for full command
                return
            }
            return
        }
        
        // Try instant persona detection for model switching
        if let persona = PersonaDetector.detectPersonaForSwitching(from: text) {
            // Update session immediately
            PersonaSessionManager.shared.setCurrentPersona(persona)
            // Switch to appropriate model
            switchToDefaultModel(for: persona)
        }
    }
    
    /// Switch to the default model for the given persona
    private func switchToDefaultModel(for persona: String) {
        // Determine persona type
        let personaType: PersonaMappingLoader.PersonaType = (persona == "claude") ? .claude : .nonClaude
        
        // Get default model for persona type
        guard let defaultModel = PersonaMappingLoader.getDefaultModel(for: personaType) else {
            return
        }
        
        // Switch to the model with provider prefix
        let modelWithPrefix = switch personaType {
        case .claude:
            "anthropic:\(defaultModel)"
        case .nonClaude:
            "openai:\(defaultModel)"
        }
        
        runtimeModelManager.selectedModel = modelWithPrefix
    }
    
    /// Handle delete command execution
    private func handleDeleteCommand(_ commandText: String) {
        // Parse the delete command
        guard let deleteCommand = DeleteCommandParser.parse(commandText: commandText) else {
            // Invalid syntax - do nothing silently
            return
        }
        
        // Get vault path from existing provider
        let vaultPath = VaultPathProvider.vaultPath
        let deletionService = TurnDeletionService(vaultPath: vaultPath)
        
        // Get current messages
        let currentMessages = messageStore.messages
        let turns = TurnManager.shared.calculateTurns(from: currentMessages)
        
        // Execute deletion on files
        let deletionResult = deletionService.deleteTurns(command: deleteCommand, from: currentMessages)
        
        // Update UI to match file deletions
        switch deleteCommand.scope {
        case .allTurns:
            // Use existing clearMessages method
            messageStore.clearMessages()
        case .lastTurns(let count):
            // Remove specific turns
            let turnsToRemove = Array(turns.suffix(count))
            messageStore.removeTurns(turnsToRemove)
        }
    }
    
}