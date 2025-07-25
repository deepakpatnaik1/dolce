//
//  MessageStore.swift
//  Dolce
//
//  Pure UI state management for conversation messages
//
//  ATOMIC RESPONSIBILITY: Message array state for SwiftUI only
//  - Holds @Published messages array for UI display
//  - Provides methods to add/update messages
//  - Zero business logic - no LLM calls, no file operations, no persona parsing
//  - Business logic handled by separate service layers
//

import Foundation
import SwiftUI
import Combine

@MainActor
class MessageStore: ObservableObject {
    @Published var messages: [ChatMessage] = []
    private let persistenceService: MessagePersistenceService
    
    init(persistenceService: MessagePersistenceService = MessagePersistenceService()) {
        self.persistenceService = persistenceService
        
        // Load persisted messages if memory system is enabled
        if AppConfigurationLoader.isMemorySystemEnabled {
            messages = persistenceService.loadPersistedMessages()
        }
    }
    
    // MARK: - Message State Management
    
    /// Add new message to conversation
    func addMessage(_ message: ChatMessage) {
        messages.append(message)
    }
    
    /// Add new message with content and author
    func addMessage(content: String, author: String, persona: String? = nil) {
        let message = ChatMessage(content: content, author: author, persona: persona)
        messages.append(message)
    }
    
    /// Update existing message content (for streaming)
    func updateMessage(id: UUID, content: String) {
        guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
        
        let originalMessage = messages[index]
        let updatedMessage = ChatMessage(
            id: originalMessage.id,
            content: content,
            author: originalMessage.author,
            timestamp: originalMessage.timestamp,
            persona: originalMessage.persona
        )
        messages[index] = updatedMessage
    }
    
    /// Create empty message for streaming and return its ID
    func startStreamingMessage(author: String, persona: String? = nil) -> UUID {
        let message = ChatMessage(content: "", author: author, persona: persona)
        let messageId = message.id
        messages.append(message)
        return messageId
    }
    
    /// Clear all messages
    func clearMessages() {
        messages.removeAll()
    }
    
}