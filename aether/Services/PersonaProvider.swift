//
//  PersonaProvider.swift
//  Aether
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
    
    /// Get available personas from vault
    static func getAvailablePersonas() -> [String] {
        return VaultPersonaLoader.discoverPersonas()
    }
    
    /// Check if persona is valid
    static func isValidPersona(_ persona: String) -> Bool {
        return VaultPersonaLoader.personaExists(persona)
    }
    
    /// Get default persona from configuration
    static func getDefaultPersona() -> String {
        return AppConfigurationLoader.defaultPersona
    }
}