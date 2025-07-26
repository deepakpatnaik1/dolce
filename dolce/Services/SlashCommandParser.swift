//
//  SlashCommandParser.swift
//  Dolce
//
//  Service for parsing and validating slash commands
//
//  ATOMIC RESPONSIBILITY: Parse slash commands from text
//  - Detect slash command presence
//  - Validate command syntax
//  - Extract command and remaining text
//  - Zero UI logic, zero execution logic
//

import Foundation

struct SlashCommandParser {
    
    /// Parse slash command from input text
    static func parseCommand(from text: String) -> SlashCommand? {
        return SlashCommand.parse(from: text)
    }
    
    /// Check if text contains a slash command at the beginning
    static func hasCommand(in text: String) -> Bool {
        return parseCommand(from: text) != nil
    }
    
    /// Extract text after removing slash command
    static func extractTextAfterCommand(from text: String, command: SlashCommand) -> String {
        return SlashCommand.extractText(from: text, command: command)
    }
    
    /// Check if the text is exactly a slash command with no additional content
    static func isExactCommand(_ text: String) -> Bool {
        return SlashCommand.isExactCommand(text: text)
    }
    
    /// Determine if a slash command should be executed
    /// (Only execute if it's the exact command with no additional text)
    static func shouldExecuteCommand(in text: String) -> SlashCommand? {
        guard isExactCommand(text) else { return nil }
        return parseCommand(from: text)
    }
}