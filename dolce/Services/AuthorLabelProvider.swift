//
//  AuthorLabelProvider.swift
//  Dolce
//
//  Atomic service for providing consistent author labels
//
//  ATOMIC RESPONSIBILITY: Provide author labels for messages only
//  - Return appropriate labels for user, AI, and system messages
//  - Use configuration-driven labels (Boss instead of User)
//  - Handle persona-specific author labels
//  - Zero business logic, pure label transformation
//

import Foundation

struct AuthorLabelProvider {
    
    /// Get author label for user messages
    static func getUserLabel() -> String {
        return VaultPersonaLoader.getBossLabel()
    }
    
    /// Get author label for AI messages with persona
    static func getAILabel(persona: String) -> String {
        return persona
    }
    
    /// Get author label for system messages
    static func getSystemLabel() -> String {
        return "System"
    }
    
    /// Check if author is the user/boss
    static func isUserAuthor(_ author: String) -> Bool {
        return author == getUserLabel()
    }
    
    /// Check if author is a system message
    static func isSystemAuthor(_ author: String) -> Bool {
        return author == getSystemLabel()
    }
}