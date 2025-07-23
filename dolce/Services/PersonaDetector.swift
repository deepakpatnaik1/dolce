//
//  PersonaDetector.swift
//  Dolce
//
//  Detect persona from input text
//
//  ATOMIC RESPONSIBILITY: Parse persona from user input only
//  - Detect persona name in first word
//  - Strip persona from input text
//  - Case-insensitive matching
//  - Zero business logic - pure text parsing
//

import Foundation

struct PersonaDetector {
    
    /// Detect persona from the beginning of input text
    /// Returns lowercased persona name if found
    static func detectPersona(from input: String) -> String? {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Get first word
        let words = trimmed.components(separatedBy: .whitespaces)
        guard let firstWord = words.first, !firstWord.isEmpty else {
            return nil
        }
        
        // Clean first word (remove punctuation like "Claude," -> "claude")
        let cleanedWord = firstWord
            .trimmingCharacters(in: .punctuationCharacters)
            .lowercased()
        
        // Check if it's a known persona
        let knownPersonas = VaultPersonaLoader.discoverPersonas()
        if knownPersonas.contains(cleanedWord) {
            return cleanedWord
        }
        
        return nil
    }
    
    /// Strip persona name from input and return clean message
    static func stripPersonaFromInput(_ input: String) -> String {
        let trimmed = input.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Check if first word is a persona
        guard detectPersona(from: input) != nil else {
            return trimmed
        }
        
        // Remove first word
        let words = trimmed.components(separatedBy: .whitespaces)
        let remainingWords = Array(words.dropFirst())
        return remainingWords.joined(separator: " ")
    }
    
    /// Check if input starts with a specific persona
    static func inputStartsWithPersona(_ input: String, persona: String) -> Bool {
        let detectedPersona = detectPersona(from: input)
        return detectedPersona?.lowercased() == persona.lowercased()
    }
}