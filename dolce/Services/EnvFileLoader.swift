//
//  EnvFileLoader.swift
//  Dolce
//
//  Atomic environment file loader
//
//  ATOMIC RESPONSIBILITY: Load environment variables from .env file only
//  - Read .env file from project root
//  - Parse key=value pairs
//  - Provide clean dictionary interface
//  - Zero API logic, zero configuration logic
//

import Foundation

struct EnvFileLoader {
    
    /// Dictionary to store loaded environment variables
    static var loadedEnvVars: [String: String] = [:]
    static var hasLoaded: Bool = false
    
    /// Load environment variables from .env file
    static func loadEnvFile() {
        // Only load once per app session
        guard !hasLoaded else { return }
        
        // Find .env file in project root
        guard let envFileURL = findEnvFile() else {
            hasLoaded = true
            return
        }
        
        do {
            let envContent = try String(contentsOf: envFileURL, encoding: .utf8)
            loadedEnvVars = parseEnvContent(envContent)
            hasLoaded = true
        } catch {
            hasLoaded = true
        }
    }
    
    /// Get environment variable value (from loaded .env or system)
    static func getEnvVar(_ key: String) -> String? {
        // Ensure .env file is loaded
        loadEnvFile()
        
        // Check loaded .env variables first, then system environment
        return loadedEnvVars[key] ?? ProcessInfo.processInfo.environment[key]
    }
    
    // MARK: - Private Helpers
    
    /// Find .env file in app bundle
    private static func findEnvFile() -> URL? {
        
        // Check app bundle first (where we have permission to read)
        if let bundlePath = Bundle.main.path(forResource: ".env", ofType: nil) {
            let envFile = URL(fileURLWithPath: bundlePath)
            return envFile
        }
        
        return nil
    }
    
    /// Parse .env file content into key-value pairs
    private static func parseEnvContent(_ content: String) -> [String: String] {
        var envVars: [String: String] = [:]
        
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Skip empty lines and comments
            if trimmedLine.isEmpty || trimmedLine.hasPrefix("#") {
                continue
            }
            
            // Parse KEY=VALUE format
            let parts = trimmedLine.components(separatedBy: "=")
            if parts.count >= 2 {
                let key = parts[0].trimmingCharacters(in: .whitespaces)
                let value = parts[1...].joined(separator: "=").trimmingCharacters(in: .whitespaces)
                
                // Remove quotes if present
                let cleanValue = value.trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                
                envVars[key] = cleanValue
            }
        }
        
        return envVars
    }
}