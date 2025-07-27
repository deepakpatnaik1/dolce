//
//  VaultPathProvider.swift
//  Aether
//
//  Atomic vault path provider
//
//  ATOMIC RESPONSIBILITY: Provide vault paths only
//  - Determine correct vault path based on environment
//  - Handle both development and production scenarios
//  - Provide consistent paths for all vault resources
//  - Zero file operations, zero loading logic
//

import Foundation

struct VaultPathProvider {
    
    /// Get the base vault path
    static var vaultPath: String {
        // In development, use the source directory
        // In production, the vault should be copied to app bundle or a known location
        
        // First, try to find vault relative to current executable
        if let executablePath = Bundle.main.executablePath {
            let executableURL = URL(fileURLWithPath: executablePath)
            
            // Go up from executable to find project root
            // Structure: .../aether.app/Contents/MacOS/aether
            // We need to go up to find aetherVault
            var currentURL = executableURL
            
            // Try different levels up from executable
            for _ in 0..<10 {
                currentURL = currentURL.deletingLastPathComponent()
                let vaultURL = currentURL.appendingPathComponent("aetherVault")
                
                if FileManager.default.fileExists(atPath: vaultURL.path) {
                    return vaultURL.path
                }
            }
        }
        
        // Check environment variable
        if let envPath = ProcessInfo.processInfo.environment["AETHER_VAULT_PATH"] {
            if FileManager.default.fileExists(atPath: envPath) {
                return envPath
            }
        }
        
        // Fallback to hardcoded path for development
        // TODO: This is user-specific and should be removed for production
        let fallbackPath = "/Users/d.patnaik/code/aether/aetherVault"
        if FileManager.default.fileExists(atPath: fallbackPath) {
            return fallbackPath
        }
        
        // Last resort - look for vault in current directory
        let currentDirVault = FileManager.default.currentDirectoryPath + "/aetherVault"
        if FileManager.default.fileExists(atPath: currentDirVault) {
            return currentDirVault
        }
        
        // If nothing works, return the fallback (will likely fail but provides clear error)
        return fallbackPath
    }
    
    /// Get path for config file
    static func configPath(for filename: String) -> String {
        return "\(vaultPath)/config/\(filename)"
    }
    
    /// Get path for persona folder
    static func personaPath(for personaName: String) -> String {
        return "\(vaultPath)/playbook/personas/\(personaName)"
    }
    
    /// Get boss persona path
    static var bossPath: String {
        return "\(vaultPath)/playbook/boss"
    }
    
    /// Get all persona folders path
    static var personasPath: String {
        return "\(vaultPath)/playbook/personas"
    }
}