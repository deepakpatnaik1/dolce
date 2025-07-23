//
//  AppConfigurationLoader.swift
//  Dolce
//
//  Load application configuration from vault
//
//  ATOMIC RESPONSIBILITY: Load and provide app configuration only
//  - Read app-configuration.json from vault
//  - Provide typed access to configuration values
//  - Cache configuration for performance
//  - Zero business logic, zero side effects
//

import Foundation

struct AppConfigurationLoader {
    
    private struct AppConfig: Codable {
        let fileHandling: FileHandling
        let conversation: Conversation
        let defaults: Defaults
        
        struct FileHandling: Codable {
            let maxFileSizeMB: Int
            let contentTruncation: ContentTruncation
            
            struct ContentTruncation: Codable {
                let filePreviewChars: Int
                let messageContentChars: Int
            }
        }
        
        struct Conversation: Codable {
            let defaultPersona: String
            let maxHistoryLength: Int
            let temperature: Double
        }
        
        struct Defaults: Codable {
            let fallbackProvider: String
        }
    }
    
    private static var cachedConfig: AppConfig?
    
    /// Load configuration from JSON file
    private static func loadConfig() -> AppConfig? {
        if let cached = cachedConfig {
            return cached
        }
        
        let configPath = VaultPathProvider.configPath(for: "app-configuration.json")
        
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: configPath))
            let config = try JSONDecoder().decode(AppConfig.self, from: data)
            cachedConfig = config
            return config
        } catch {
            // Fallback to defaults if config can't be loaded
            return nil
        }
    }
    
    // MARK: - Public Accessors
    
    /// Get max file size in bytes
    static var maxFileSize: Int64 {
        let config = loadConfig()
        let sizeMB = config?.fileHandling.maxFileSizeMB ?? 10
        return Int64(sizeMB * 1024 * 1024)
    }
    
    /// Get file preview character limit
    static var filePreviewCharLimit: Int {
        return loadConfig()?.fileHandling.contentTruncation.filePreviewChars ?? 2000
    }
    
    /// Get message content character limit
    static var messageContentCharLimit: Int {
        return loadConfig()?.fileHandling.contentTruncation.messageContentChars ?? 3000
    }
    
    /// Get default persona
    static var defaultPersona: String {
        return loadConfig()?.conversation.defaultPersona ?? "claude"
    }
    
    /// Get max conversation history length
    static var maxHistoryLength: Int {
        return loadConfig()?.conversation.maxHistoryLength ?? 50
    }
    
    /// Get conversation temperature
    static var temperature: Double {
        return loadConfig()?.conversation.temperature ?? 0.7
    }
    
    /// Get fallback provider
    static var fallbackProvider: String {
        return loadConfig()?.defaults.fallbackProvider ?? "anthropic"
    }
    
    /// Clear cached configuration
    static func clearCache() {
        cachedConfig = nil
    }
}