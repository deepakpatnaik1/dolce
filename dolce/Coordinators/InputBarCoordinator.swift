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

@MainActor
class InputBarCoordinator: ObservableObject {
    private let conversationOrchestrator: ConversationOrchestrator
    private let fileDropHandler: FileDropHandler
    private let turnModeCoordinator = TurnModeCoordinator.shared
    private let messageStore: MessageStore
    private let runtimeModelManager = RuntimeModelManager.shared
    
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
        
        // Detect persona from message
        var finalText = trimmedText
        var targetPersona: String
        
        if let detected = PersonaDetector.detectPersona(from: trimmedText) {
            // Persona detected - switch to it
            finalText = detected.cleanedMessage
            targetPersona = detected.persona
            
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
                print("Failed to read file: \(error)")
            }
            
        case .failure(let error):
            // Log validation error but continue
            print("File validation failed: \(error)")
        }
    }
    
    // MARK: - Persona Detection and Model Switching
    
    /// Handle text changes to detect persona and switch models
    func handleTextChange(_ text: String) {
        // Detect persona from input
        if let detected = PersonaDetector.detectPersona(from: text) {
            switchToDefaultModel(for: detected.persona)
        }
    }
    
    /// Switch to the default model for the given persona
    private func switchToDefaultModel(for persona: String) {
        // Determine persona type
        let personaType: PersonaMappingLoader.PersonaType = (persona == "claude") ? .claude : .nonClaude
        
        // Get default model for persona type
        guard let defaultModel = PersonaMappingLoader.getDefaultModel(for: personaType) else {
            print("No default model found for persona type: \(personaType)")
            return
        }
        
        print("Switching to persona: \(persona), model: \(defaultModel)")
        
        // Switch to the model with provider prefix
        let modelWithPrefix = switch personaType {
        case .claude:
            "anthropic:\(defaultModel)"
        case .nonClaude:
            "openai:\(defaultModel)"
        }
        
        print("Setting selectedModel to: \(modelWithPrefix)")
        runtimeModelManager.selectedModel = modelWithPrefix
        
        // Verify the model was set
        print("Current selectedModel: \(runtimeModelManager.selectedModel)")
    }
    
}