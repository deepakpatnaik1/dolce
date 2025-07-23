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
        
        // Compose message
        let messageContent = MessageComposer.compose(
            text: trimmedText,
            files: fileDropHandler.droppedFiles
        )
        
        // Capture attachments before clearing
        let attachments = fileDropHandler.droppedFiles
        
        // Clear UI state
        state.clearInput()
        fileDropHandler.clearFiles()
        
        // Send message
        await conversationOrchestrator.sendMessageWithAttachments(
            messageContent,
            attachments: attachments
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
}