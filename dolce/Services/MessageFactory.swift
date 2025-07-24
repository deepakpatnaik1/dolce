//
//  MessageFactory.swift
//  Dolce
//
//  Atomic factory for creating chat messages
//
//  ATOMIC RESPONSIBILITY: Create ChatMessage instances only
//  - Create user messages with proper author labels
//  - Create AI messages with persona information
//  - Create system/error messages
//  - Zero business logic, pure message creation
//

import Foundation

struct MessageFactory {
    
    /// Create a user message
    static func createUserMessage(content: String, attachments: [DroppedFile]? = nil) -> ChatMessage {
        return ChatMessage(
            content: content,
            author: AuthorLabelProvider.getUserLabel(),
            persona: nil,
            attachments: attachments
        )
    }
    
    /// Create an AI message
    static func createAIMessage(content: String, persona: String) -> ChatMessage {
        return ChatMessage(
            content: content,
            author: AuthorLabelProvider.getAILabel(persona: persona),
            persona: persona
        )
    }
    
    /// Create a system/error message
    static func createSystemMessage(content: String) -> ChatMessage {
        return ChatMessage(
            content: content,
            author: AuthorLabelProvider.getSystemLabel(),
            persona: nil
        )
    }
    
    /// Create an empty AI message for streaming
    static func createStreamingAIMessage(persona: String) -> ChatMessage {
        return ChatMessage(
            content: "",
            author: AuthorLabelProvider.getAILabel(persona: persona),
            persona: persona
        )
    }
}