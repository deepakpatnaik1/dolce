//
//  PersonaSessionManager.swift
//  Dolce
//
//  Track current conversation persona
//
//  ATOMIC RESPONSIBILITY: Manage current persona session only
//  - Store the current active persona
//  - Provide access to current persona
//  - Update when persona switches
//  - Zero message logic, zero model logic
//

import Foundation
import SwiftUI

@MainActor
class PersonaSessionManager: ObservableObject {
    static let shared = PersonaSessionManager()
    
    @Published private(set) var currentPersona: String
    
    private init() {
        // Start with default persona from configuration
        let defaultPersona = AppConfigurationLoader.defaultPersona
        if PersonaProvider.isValidPersona(defaultPersona) {
            self.currentPersona = defaultPersona
        } else {
            // Fallback to first available persona
            let personas = VaultPersonaLoader.discoverPersonas()
            self.currentPersona = personas.first ?? "assistant"
        }
    }
    
    /// Update the current persona
    func setCurrentPersona(_ persona: String) {
        currentPersona = persona
    }
    
    /// Get the current persona
    func getCurrentPersona() -> String {
        return currentPersona
    }
    
    /// Reset to default persona
    func resetToDefault() {
        let defaultPersona = AppConfigurationLoader.defaultPersona
        if PersonaProvider.isValidPersona(defaultPersona) {
            currentPersona = defaultPersona
        } else {
            let personas = VaultPersonaLoader.discoverPersonas()
            currentPersona = personas.first ?? "assistant"
        }
    }
}