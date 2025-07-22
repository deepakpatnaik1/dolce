//
//  APIConfigurationProvider.swift
//  Dolce
//
//  Atomic API configuration provider
//
//  ATOMIC RESPONSIBILITY: Provide API configurations only
//  - Build APIConfiguration objects for different providers
//  - Handle default configuration selection
//  - Basic configuration validation
//  - Zero key management, zero persona logic
//

import Foundation

// MARK: - Configuration Data Models

struct APIConfiguration {
    let provider: APIProvider
    let baseURL: String
    let apiKey: String
    let model: String
    let maxTokens: Int
    let headers: [String: String]
}

struct ConversationSettings {
    let defaultPersona: String
    let maxHistoryLength: Int
    let streamingEnabled: Bool
    let temperature: Double
}

// MARK: - API Configuration Provider

struct APIConfigurationProvider {
    
    /// Get Anthropic API configuration
    static func getAnthropicConfig() -> APIConfiguration? {
        guard let apiKey = APIKeyManager.getAPIKey(for: "ANTHROPIC_API_KEY") else {
            return nil
        }
        
        return APIConfiguration(
            provider: .anthropic,
            baseURL: "https://api.anthropic.com/v1",
            apiKey: apiKey,
            model: "claude-3-5-sonnet-20241022",
            maxTokens: 1000,
            headers: ["anthropic-version": "2023-06-01", "x-api-key": apiKey]
        )
    }
    
    /// Get OpenAI API configuration
    static func getOpenAIConfig() -> APIConfiguration? {
        guard let apiKey = APIKeyManager.getAPIKey(for: "OPENAI_API_KEY") else {
            return nil
        }
        
        return APIConfiguration(
            provider: .openai,
            baseURL: "https://api.openai.com/v1/chat/completions",
            apiKey: apiKey,
            model: "gpt-4",
            maxTokens: 1000,
            headers: [:]
        )
    }
    
    /// Get default API configuration
    static func getDefaultConfig() -> APIConfiguration? {
        // Try Anthropic first, fallback to OpenAI
        return getAnthropicConfig() ?? getOpenAIConfig()
    }
    
    /// Get default conversation settings
    static func getConversationSettings() -> ConversationSettings {
        return ConversationSettings(
            defaultPersona: "claude",
            maxHistoryLength: 50,
            streamingEnabled: true,
            temperature: 0.7
        )
    }
    
    /// Check if API configuration is valid
    static func isConfigurationValid() -> Bool {
        return getDefaultConfig() != nil
    }
    
    /// Get human-readable configuration status
    static func getConfigurationStatus() -> String {
        if getAnthropicConfig() != nil {
            return "Anthropic API configured"
        } else if getOpenAIConfig() != nil {
            return "OpenAI API configured"
        } else {
            return "No API keys configured"
        }
    }
}