//
//  AnthropicMemoryService.swift
//  Aether
//
//  Atomic memory service for Anthropic provider
//
//  ATOMIC RESPONSIBILITY: Handle Anthropic-specific memory requests only
//  - Build Anthropic-specific request format
//  - Execute request via HTTPExecutor
//  - Parse Anthropic response
//  - Zero orchestration logic, zero shared state
//

import Foundation

struct AnthropicMemoryService {
    
    func sendRequest(systemPrompt: String, userMessage: String, model: String) async throws -> String {
        // Get configuration from models.json
        guard let providerConfig = ModelProvider.getProviderConfig(for: "anthropic"),
              let modelConfig = providerConfig.models.first(where: { $0.key == model }) else {
            throw MemoryServiceError.configurationNotFound
        }
        
        // Get API key
        guard let apiKeyIdentifier = providerConfig.apiKeyIdentifier,
              let apiKey = APIKeyManager.getAPIKey(for: apiKeyIdentifier) else {
            throw MemoryServiceError.apiKeyNotFound
        }
        
        // Build request body
        let requestBody = RequestBodyBuilder.buildSingleMessageBody(
            message: userMessage,
            model: model,
            maxTokens: modelConfig.maxTokens,
            streaming: false,
            additionalParams: ["system": systemPrompt]
        )
        
        // Build headers
        var headers = providerConfig.additionalHeaders ?? [:]
        if let authHeader = providerConfig.authHeader {
            headers[authHeader] = apiKey
        }
        
        // Build request
        let request = try HTTPRequestBuilder.buildRequest(
            baseURL: providerConfig.baseURL,
            endpoint: providerConfig.endpoint,
            apiKey: apiKey,
            requestBody: requestBody,
            headers: headers
        )
        
        // Execute request
        let (data, _) = try await HTTPExecutor.executeRequest(request)
        
        // Parse response
        guard let response = ResponseParser.parseResponse(data, provider: .anthropic) else {
            throw MemoryServiceError.parseError
        }
        
        return response.content
    }
}

enum MemoryServiceError: LocalizedError {
    case configurationNotFound
    case apiKeyNotFound
    case parseError
    
    var errorDescription: String? {
        switch self {
        case .configurationNotFound:
            return "Provider configuration not found"
        case .apiKeyNotFound:
            return "API key not found"
        case .parseError:
            return "Failed to parse response"
        }
    }
}