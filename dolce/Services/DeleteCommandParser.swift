//
//  DeleteCommandParser.swift
//  Dolce
//
//  Service for parsing delete command syntax
//
//  ATOMIC RESPONSIBILITY: Parse delete commands from text
//  - Parse /delete last-X syntax
//  - Parse /delete all syntax
//  - Return nil for invalid syntax (no errors)
//  - Zero UI logic, zero execution logic
//

import Foundation

struct DeleteCommandParser {
    // Constants for command syntax
    private static let allKeyword = "all"
    private static let lastPrefix = "last-"
    
    /// Parse delete command from text after /delete prefix
    /// Returns nil for invalid syntax (no error thrown)
    static func parse(commandText: String) -> DeleteCommand? {
        let trimmed = commandText.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Handle "/delete all"
        if trimmed == allKeyword {
            return DeleteCommand(scope: .allTurns)
        }
        
        // Handle "/delete last-X"
        if trimmed.hasPrefix(lastPrefix) {
            let numberPart = String(trimmed.dropFirst(lastPrefix.count))
            if let count = Int(numberPart), count > 0 {
                return DeleteCommand(scope: .lastTurns(count: count))
            }
        }
        
        // Invalid syntax - return nil
        return nil
    }
}