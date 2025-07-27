//
//  PersonaDetector.swift
//  Aether
//
//  Detect persona names at the start of messages
//
//  ATOMIC RESPONSIBILITY: Parse persona from message text only
//  - Check if message starts with a persona name
//  - Extract persona and return cleaned message
//  - Validate against available personas
//  - Zero state management, zero side effects
//

import Foundation

struct PersonaDetector {
    
    /// Detect persona from message and return cleaned text
    /// Returns: (personaName, cleanedMessage) or nil if no persona detected
    static func detectPersona(from message: String) -> (persona: String, cleanedMessage: String)? {
        // Trim whitespace
        let trimmedMessage = message.trimmingCharacters(in: .whitespaces)
        
        // Empty message check
        guard !trimmedMessage.isEmpty else {
            return nil
        }
        
        // Split by first space to get potential persona
        let components = trimmedMessage.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
        
        guard components.count >= 1 else {
            return nil
        }
        
        let firstWord = String(components[0]).lowercased()
        
        // Remove trailing punctuation from first word if present
        let cleanedFirstWord = firstWord.trimmingCharacters(in: CharacterSet(charactersIn: ",:"))
        
        // Get the remainder of the message
        let remainder: String
        if components.count > 1 {
            remainder = String(components[1])
        } else if firstWord != cleanedFirstWord {
            // Had punctuation but no text after (e.g., "Claude,")
            remainder = ""
        } else {
            // Just one word with no separator or following text
            return nil
        }
        
        // No persona pattern found if remainder is empty and no punctuation
        guard !remainder.isEmpty || firstWord != cleanedFirstWord else {
            return nil
        }
        
        // Validate against available personas
        let availablePersonas = VaultPersonaLoader.discoverPersonas()
        
        // Check if detected word is a valid persona
        if availablePersonas.contains(cleanedFirstWord) {
            return (cleanedFirstWord, remainder)
        }
        
        // Special case for "Boss" - the user
        if cleanedFirstWord == "boss" {
            // Boss addressing themselves? Ignore
            return nil
        }
        
        return nil
    }
    
    /// Check if a word is a valid persona name
    static func isValidPersona(_ name: String) -> Bool {
        let availablePersonas = VaultPersonaLoader.discoverPersonas()
        return availablePersonas.contains(name.lowercased())
    }
    
    /// Detect persona for instant model switching (no punctuation required)
    /// Returns persona name if the entire text matches a persona name
    static func detectPersonaForSwitching(from text: String) -> String? {
        let trimmed = text.trimmingCharacters(in: .whitespaces).lowercased()
        
        // Empty check
        guard !trimmed.isEmpty else {
            return nil
        }
        
        // Get available personas
        let availablePersonas = VaultPersonaLoader.discoverPersonas()
        
        // Check if the entire text is a persona name
        if availablePersonas.contains(trimmed) {
            return trimmed
        }
        
        // Also check if text is a persona name with trailing punctuation
        let withoutPunctuation = trimmed.trimmingCharacters(in: CharacterSet(charactersIn: ",:"))
        if withoutPunctuation != trimmed && availablePersonas.contains(withoutPunctuation) {
            return withoutPunctuation
        }
        
        return nil
    }
}