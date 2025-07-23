//
//  PersonaMappingLoader.swift
//  Dolce
//
//  Load provider-persona mapping configuration
//
//  ATOMIC RESPONSIBILITY: Read and parse provider-persona mappings only
//  - Load default models for persona types
//  - Check persona-provider exclusivity
//  - Get exclusive providers for personas
//  - Zero business logic - pure configuration loading
//

import Foundation

struct PersonaMappingLoader {
    private static let configPath = "/Users/d.patnaik/code/dolce/dolceVault/config/provider-persona-mapping.json"
    
    enum PersonaType {
        case claude
        case nonClaude
    }
    
    private struct MappingConfig: Codable {
        let defaultModels: DefaultModels
        let providerExclusivePersonas: [String: [String]]
        
        struct DefaultModels: Codable {
            let claudeProvider: String
            let nonClaudeProvider: String
        }
    }
    
    private static var cachedConfig: MappingConfig?
    
    /// Load configuration from JSON file
    private static func loadConfig() -> MappingConfig? {
        if let cached = cachedConfig {
            return cached
        }
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
            let config = try JSONDecoder().decode(MappingConfig.self, from: data)
            cachedConfig = config
            return config
        } catch {
            print("Error loading persona mapping config: \(error)")
            return nil
        }
    }
    
    /// Get default model for persona type
    static func getDefaultModel(for personaType: PersonaType) -> String? {
        guard let config = loadConfig() else { return nil }
        
        switch personaType {
        case .claude:
            return config.defaultModels.claudeProvider
        case .nonClaude:
            return config.defaultModels.nonClaudeProvider
        }
    }
    
    /// Check if persona is exclusive to a specific provider
    static func isPersonaExclusiveToProvider(persona: String, provider: String) -> Bool {
        guard let config = loadConfig() else { return false }
        
        let lowercasePersona = persona.lowercased()
        
        // Check if provider has exclusive personas
        if let exclusivePersonas = config.providerExclusivePersonas[provider] {
            return exclusivePersonas.contains(lowercasePersona)
        }
        
        return false
    }
    
    /// Get the exclusive provider for a persona (if any)
    static func getExclusiveProvider(for persona: String) -> String? {
        guard let config = loadConfig() else { return nil }
        
        let lowercasePersona = persona.lowercased()
        
        // Check all providers for exclusive personas
        for (provider, exclusivePersonas) in config.providerExclusivePersonas {
            if exclusivePersonas.contains(lowercasePersona) {
                return provider
            }
        }
        
        return nil
    }
    
    /// Check if a provider can work with a persona
    static func canProviderWorkWithPersona(provider: String, persona: String) -> Bool {
        let lowercasePersona = persona.lowercased()
        
        // Check if persona has an exclusive provider
        if let exclusiveProvider = getExclusiveProvider(for: lowercasePersona) {
            return provider == exclusiveProvider
        }
        
        // Check if provider has exclusive personas (and this isn't one of them)
        if isProviderExclusive(provider) {
            return isPersonaExclusiveToProvider(persona: lowercasePersona, provider: provider)
        }
        
        // No restrictions - can work together
        return true
    }
    
    /// Check if a provider has exclusive personas
    private static func isProviderExclusive(_ provider: String) -> Bool {
        guard let config = loadConfig() else { return false }
        return config.providerExclusivePersonas[provider] != nil
    }
    
    /// Clear cached configuration (useful for reloading after changes)
    static func clearCache() {
        cachedConfig = nil
    }
}