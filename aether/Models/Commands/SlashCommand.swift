//
//  SlashCommand.swift
//  Aether
//
//  Model for slash command representation
//
//  ATOMIC RESPONSIBILITY: Pure data structure for slash commands
//  - Define available slash commands
//  - Parse command from text
//  - Extract command portion from input
//  - Zero logic beyond parsing - pure data model
//

import Foundation

enum SlashCommand: String, CaseIterable {
    case delete = "/delete"
    
    /// Parse slash command from input text
    static func parse(from text: String) -> SlashCommand? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if text starts with a slash command
        for command in SlashCommand.allCases {
            if trimmed.lowercased().hasPrefix(command.rawValue) {
                return command
            }
        }
        
        return nil
    }
    
    /// Extract command text from input (removes the slash command portion)
    static func extractText(from input: String, command: SlashCommand) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove command prefix (case-insensitive)
        if trimmed.lowercased().hasPrefix(command.rawValue) {
            let startIndex = trimmed.index(trimmed.startIndex, offsetBy: command.rawValue.count)
            let remainingText = String(trimmed[startIndex...])
            return remainingText.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        return trimmed
    }
    
    /// Check if input text is exactly a slash command (no additional text)
    static func isExactCommand(text: String) -> Bool {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return SlashCommand.allCases.contains { $0.rawValue.lowercased() == trimmed.lowercased() }
    }
}