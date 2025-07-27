//
//  PathConfiguration.swift
//  Aether
//
//  Centralized path constants to eliminate hardcoding
//
//  ATOMIC RESPONSIBILITY: Provide all file system paths as constants
//  - Single source of truth for all paths
//  - Zero business logic, pure constants
//  - Enables easy configuration changes
//

import Foundation

struct PathConfiguration {
    
    // MARK: - Vault Structure Paths
    
    /// Playbook paths
    static let playbookPath = "playbook"
    static let toolsPath = "playbook/tools"
    static let bossPath = "playbook/boss"
    static let personasPath = "playbook/personas"
    
    /// Journal paths
    static let journalPath = "journal"
    static let superjournalPath = "superjournal"
    
    /// App state path
    static let appStatePath = ".app-state"
    
    // MARK: - Specific File Names
    
    /// Tool files
    static let instructionsFile = "instructions-to-llm.md"
    static let taxonomyFile = "taxonomy.json"
    static let currentPersonaFile = "currentPersona.md"
    
    /// State files
    static let scrollPositionFile = "scrollPosition.json"
    
    /// Configuration files
    static let designTokensFile = "design-tokens.json"
    static let modelsFile = "models.json"
    static let appConfigFile = "app-configuration.json"
    static let providerMappingFile = "provider-persona-mapping.json"
    
    // MARK: - File Extensions
    
    static let markdownExtension = ".md"
    static let jsonExtension = ".json"
    
    // MARK: - Computed Full Paths
    
    /// Full path to instructions file
    static var instructionsPath: String {
        "\(toolsPath)/\(instructionsFile)"
    }
    
    /// Full path to taxonomy file
    static var taxonomyPath: String {
        "\(toolsPath)/\(taxonomyFile)"
    }
    
    /// Full path to current persona file
    static var currentPersonaPath: String {
        "\(toolsPath)/\(currentPersonaFile)"
    }
    
    /// Full path to scroll position file
    static var scrollPositionPath: String {
        "\(appStatePath)/\(scrollPositionFile)"
    }
    
    /// Get persona folder path
    static func personaFolderPath(for persona: String) -> String {
        let personaName = persona.prefix(1).uppercased() + persona.dropFirst()
        return "\(personasPath)/\(personaName)"
    }
    
    /// Get persona file path
    static func personaFilePath(for persona: String) -> String {
        let personaName = persona.prefix(1).uppercased() + persona.dropFirst()
        return "\(personaFolderPath(for: persona))/\(personaName)\(markdownExtension)"
    }
}