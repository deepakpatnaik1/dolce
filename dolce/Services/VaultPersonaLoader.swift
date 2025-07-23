//
//  VaultPersonaLoader.swift
//  Dolce
//
//  Discover personas from vault filesystem
//
//  ATOMIC RESPONSIBILITY: Read persona information from vault folders only
//  - Read Boss label from boss folder
//  - Discover available personas from personas folder
//  - Check persona existence
//  - Zero business logic - pure filesystem reading
//

import Foundation

struct VaultPersonaLoader {
    private static var vaultPath: String { VaultPathProvider.vaultPath }
    private static var bossPath: String { VaultPathProvider.bossPath }
    private static var personasPath: String { VaultPathProvider.personasPath }
    
    /// Get Boss label from folder name
    static func getBossLabel() -> String {
        // Read the boss folder name
        let bossURL = URL(fileURLWithPath: bossPath)
        let folderName = bossURL.lastPathComponent
        
        // Capitalize first letter
        return folderName.prefix(1).uppercased() + folderName.dropFirst()
    }
    
    /// Discover all available personas from vault folders
    static func discoverPersonas() -> [String] {
        let fileManager = FileManager.default
        
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: personasPath)
            
            // Filter for directories only
            let personas = contents.filter { item in
                var isDirectory: ObjCBool = false
                let fullPath = "\(personasPath)/\(item)"
                fileManager.fileExists(atPath: fullPath, isDirectory: &isDirectory)
                return isDirectory.boolValue
            }
            
            // Return lowercase for consistency
            return personas.map { $0.lowercased() }
            
        } catch {
            // Silently return empty array on error
            return []
        }
    }
    
    /// Check if a persona exists in the vault
    static func personaExists(_ name: String) -> Bool {
        let personas = discoverPersonas()
        return personas.contains(name.lowercased())
    }
    
    /// Get all persona folder names (for display)
    static func getPersonaDisplayNames() -> [String: String] {
        let personas = discoverPersonas()
        var displayNames: [String: String] = [:]
        
        for persona in personas {
            // Capitalize first letter for display
            let displayName = persona.prefix(1).uppercased() + persona.dropFirst()
            displayNames[persona] = displayName
        }
        
        return displayNames
    }
}