//
//  ChatMessage.swift
//  Dolce
//
//  Pure data model for conversation messages
//
//  ATOMIC RESPONSIBILITY: Message data structure only
//  - Immutable data with unique identifier for streaming updates
//  - Support for both user and AI messages
//  - Persona attribution for multi-AI conversations
//  - Zero business logic - pure data model
//

import Foundation

struct ChatMessage: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let author: String
    let timestamp: Date
    let persona: String?
    let attachments: [DroppedFile]?
    
    // New message initializer
    init(content: String, author: String, persona: String? = nil, attachments: [DroppedFile]? = nil) {
        self.id = UUID()
        self.content = content
        self.author = author
        self.timestamp = Date()
        self.persona = persona
        self.attachments = attachments
    }
    
    // Streaming update initializer - preserves ID and timestamp
    init(id: UUID, content: String, author: String, timestamp: Date, persona: String? = nil, attachments: [DroppedFile]? = nil) {
        self.id = id
        self.content = content
        self.author = author
        self.timestamp = timestamp
        self.persona = persona
        self.attachments = attachments
    }
    
    // Computed properties for display logic
    var isFromBoss: Bool {
        return author.lowercased() == "boss" || author.lowercased() == "user"
    }
    
    var displayAuthor: String {
        if isFromBoss {
            return VaultPersonaLoader.getBossLabel()
        }
        return persona?.capitalized ?? author
    }
    
    var hasAttachments: Bool {
        return attachments?.isEmpty == false
    }
    
    var attachmentCount: Int {
        return attachments?.count ?? 0
    }
}