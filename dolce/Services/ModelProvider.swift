//
//  ModelProvider.swift
//  Dolce
//
//  Atomic model provider
//
//  ATOMIC RESPONSIBILITY: Provide available LLM models only
//  - Load models from external configuration
//  - Filter models by available API keys  
//  - Provide display names and model keys
//  - Zero API logic, zero hardcoding, zero state management
//

import Foundation

// MARK: - API Provider Types

enum APIProvider {
    case anthropic
    case openai
    case fireworks
    case ollama
    case local
}

// MARK: - Data Models

struct LLMModel {
    let key: String           // e.g., "anthropic:claude-3-5-sonnet"
    let displayName: String   // e.g., "claude-3-5-sonnet"
    let provider: APIProvider
    let maxTokens: Int
}

// MARK: - Model Provider

struct ModelProvider {
    
    /// Get all available models with valid API keys
    @MainActor
    static func getAvailableModels() -> [LLMModel] {
        var availableModels: [LLMModel] = []
        let config = ModelsConfiguration.shared
        
        for (providerId, providerConfig) in config.providers {
            // Check access based on provider type
            let hasAccess: Bool
            if providerId == "ollama" {
                // Always allow Ollama models in config, check availability later
                hasAccess = true
            } else if providerId == "local" {
                hasAccess = true // Other local models are always available
            } else if let apiKeyId = providerConfig.apiKeyIdentifier {
                hasAccess = APIKeyManager.getAPIKey(for: apiKeyId) != nil
            } else {
                hasAccess = false
            }
            
            if hasAccess {
                let provider = mapStringToProvider(providerId)
                
                for modelConfig in providerConfig.models {
                    // Add all configured models (Ollama availability checked when needed)
                    let model = LLMModel(
                        key: "\(providerId):\(modelConfig.key)",
                        displayName: modelConfig.displayName,
                        provider: provider,
                        maxTokens: modelConfig.maxTokens
                    )
                    availableModels.append(model)
                    
                    // Remove the else branch since we're adding all models now
                    if false { // Never executed, but keeps structure
                        // This branch is no longer used
                    }
                }
            }
        }
        
        return availableModels
    }
    
    /// Get model by key
    @MainActor
    static func getModel(for key: String) -> LLMModel? {
        return getAvailableModels().first { $0.key == key }
    }
    
    /// Get default model (first available)
    @MainActor
    static func getDefaultModel() -> LLMModel? {
        return getAvailableModels().first
    }
    
    /// Get provider configuration by provider ID
    static func getProviderConfig(for providerId: String) -> ProviderConfiguration? {
        return ModelsConfiguration.shared.providers[providerId]
    }
    
    // MARK: - Private Helpers
    
    private static func mapStringToProvider(_ providerId: String) -> APIProvider {
        switch providerId {
        case "anthropic":
            return .anthropic
        case "openai":
            return .openai
        case "fireworks":
            return .fireworks
        case "ollama":
            return .ollama
        case "local":
            return .local
        default:
            return .anthropic // Default fallback
        }
    }
}