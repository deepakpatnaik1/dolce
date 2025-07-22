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
    let endpoint: String
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
            endpoint: "/messages",
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
            baseURL: "https://api.openai.com/v1",
            endpoint: "/chat/completions",
            apiKey: apiKey,
            model: "gpt-4.1-mini-2025-04-14",
            maxTokens: 1000,
            headers: ["Authorization": "Bearer \(apiKey)"]
        )
    }
    
    /// Get Fireworks API configuration
    static func getFireworksConfig() -> APIConfiguration? {
        guard let apiKey = APIKeyManager.getAPIKey(for: "FIREWORKS_API_KEY") else {
            return nil
        }
        
        return APIConfiguration(
            provider: .fireworks,
            baseURL: "https://api.fireworks.ai/inference/v1",
            endpoint: "/chat/completions",
            apiKey: apiKey,
            model: "llama-3-1-405b",
            maxTokens: 1000,
            headers: ["Authorization": "Bearer \(apiKey)"]
        )
    }
    
    /// Get API configuration for specific model
    static func getConfigForModel(_ modelKey: String) -> APIConfiguration? {
        guard let model = ModelProvider.getModel(for: modelKey) else {
            return nil
        }
        
        // Get provider ID string from the model's provider enum
        let providerId: String
        switch model.provider {
        case .anthropic:
            providerId = "anthropic"
        case .openai:
            providerId = "openai"
        case .fireworks:
            providerId = "fireworks"
        case .local:
            providerId = "local"
        }
        
        guard let providerConfig = ModelProvider.getProviderConfig(for: providerId) else {
            return nil
        }
        
        // Handle authentication - local models don't need API keys
        var headers = providerConfig.additionalHeaders ?? [:]
        var apiKey = ""
        
        if providerId == "local" {
            // Local models don't need authentication
            apiKey = "local"
        } else if let apiKeyId = providerConfig.apiKeyIdentifier,
                  let authHeader = providerConfig.authHeader {
            // API-based models need authentication
            guard let fetchedKey = APIKeyManager.getAPIKey(for: apiKeyId) else {
                return nil
            }
            apiKey = fetchedKey
            
            let authValue = if let prefix = providerConfig.authPrefix {
                "\(prefix) \(fetchedKey)"
            } else {
                fetchedKey
            }
            headers[authHeader] = authValue
        } else {
            return nil
        }
        
        return APIConfiguration(
            provider: model.provider,
            baseURL: providerConfig.baseURL,
            endpoint: providerConfig.endpoint,
            apiKey: apiKey,
            model: extractModelId(from: modelKey),
            maxTokens: model.maxTokens,
            headers: headers
        )
    }
    
    /// Get default API configuration
    static func getDefaultConfig() -> APIConfiguration? {
        // Try Anthropic first, fallback to OpenAI, then Fireworks
        return getAnthropicConfig() ?? getOpenAIConfig() ?? getFireworksConfig()
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
        } else if getFireworksConfig() != nil {
            return "Fireworks API configured"
        } else {
            return "No API keys configured"
        }
    }
    
    // MARK: - Private Helpers
    
    /// Extract provider ID from model key (e.g., "anthropic:claude-3-5-sonnet" -> "anthropic")
    private static func extractProviderId(from modelKey: String) -> String {
        let parts = modelKey.components(separatedBy: ":")
        return parts.count > 1 ? parts[0] : "anthropic"
    }
    
    /// Extract model ID from model key (removes provider prefix)
    private static func extractModelId(from modelKey: String) -> String {
        let parts = modelKey.components(separatedBy: ":")
        return parts.count > 1 ? parts[1] : modelKey
    }
}