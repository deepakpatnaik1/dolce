//
//  PersonaProvider.swift
//  Dolce
//
//  Atomic persona provider
//
//  ATOMIC RESPONSIBILITY: Provide persona data only
//  - List available personas
//  - Validate persona names
//  - Persona-related utilities
//  - Zero API logic, zero key management
//

import Foundation

struct PersonaProvider {
    
    /// Get available personas
    static func getAvailablePersonas() -> [String] {
        return ["claude", "samara", "vanessa", "vlad", "lyra", "eva", "alicja", "sonja", "gunnar"]
    }
    
    /// Check if persona is valid
    static func isValidPersona(_ persona: String) -> Bool {
        return getAvailablePersonas().contains(persona.lowercased())
    }
    
    /// Get default persona
    static func getDefaultPersona() -> String {
        return "claude"
    }
}