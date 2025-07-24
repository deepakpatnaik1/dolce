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
    
    
    /// Get API configuration for specific model
    @MainActor
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
        @unknown default:
            // Resilient: return nil for unknown providers
            return nil
        }
        
        guard let providerConfig = ModelProvider.getProviderConfig(for: providerId) else {
            return nil
        }
        
        // Handle authentication - local models don't need API keys
        var headers = providerConfig.additionalHeaders ?? [:]
        var apiKey = ""
        
        if let apiKeyId = providerConfig.apiKeyIdentifier,
                  let authHeader = providerConfig.authHeader {
            // API-based models need authentication
            guard let fetchedKey = APIKeyManager.getAPIKey(for: apiKeyId) else {
                return nil
            }
            apiKey = fetchedKey
            
            let authValue = if let prefix = providerConfig.authPrefix {
                "\(prefix)\(fetchedKey)"
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
    @MainActor
    static func getDefaultConfig() -> APIConfiguration? {
        // Use the default model from RuntimeModelManager which handles persona mapping
        let selectedModel = RuntimeModelManager.shared.selectedModel
        guard !selectedModel.isEmpty else {
            return nil
        }
        return getConfigForModel(selectedModel)
    }
    
    /// Get default conversation settings
    static func getConversationSettings() -> ConversationSettings {
        return ConversationSettings(
            defaultPersona: AppConfigurationLoader.defaultPersona,
            maxHistoryLength: AppConfigurationLoader.maxHistoryLength,
            streamingEnabled: true,
            temperature: AppConfigurationLoader.temperature
        )
    }
    
    /// Check if API configuration is valid
    @MainActor
    static func isConfigurationValid() -> Bool {
        // Check if we have a valid selected model
        let selectedModel = RuntimeModelManager.shared.selectedModel
        return !selectedModel.isEmpty && getConfigForModel(selectedModel) != nil
    }
    
    /// Get human-readable configuration status
    @MainActor
    static func getConfigurationStatus() -> String {
        if getDefaultConfig() != nil {
            return "API configured"
        } else {
            return "No API keys configured"
        }
    }
    
    // MARK: - Private Helpers
    
    /// Extract provider ID from model key (e.g., "anthropic:claude-3-5-sonnet" -> "anthropic")
    private static func extractProviderId(from modelKey: String) -> String {
        let parts = modelKey.components(separatedBy: ":")
        return parts.count > 1 ? parts[0] : AppConfigurationLoader.fallbackProvider
    }
    
    /// Extract model ID from model key (removes provider prefix)
    private static func extractModelId(from modelKey: String) -> String {
        let parts = modelKey.components(separatedBy: ":")
        return parts.count > 1 ? parts[1] : modelKey
    }
}