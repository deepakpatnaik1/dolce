//
//  OpenAIMemoryService.swift
//  Aether
//
//  Atomic memory service for OpenAI provider
//
//  ATOMIC RESPONSIBILITY: Handle OpenAI-specific memory requests only
//  - Build OpenAI-specific request format with system messages
//  - Execute request via HTTPExecutor
//  - Parse OpenAI response
//  - Zero orchestration logic, zero shared state
//

import Foundation

struct OpenAIMemoryService {
    
    func sendRequest(systemPrompt: String, userMessage: String, model: String) async throws -> String {
        // Get configuration from models.json
        guard let providerConfig = ModelProvider.getProviderConfig(for: "openai"),
              let modelConfig = providerConfig.models.first(where: { $0.key == model }) else {
            throw MemoryServiceError.configurationNotFound
        }
        
        // Get API key
        guard let apiKeyIdentifier = providerConfig.apiKeyIdentifier,
              let apiKey = APIKeyManager.getAPIKey(for: apiKeyIdentifier) else {
            throw MemoryServiceError.apiKeyNotFound
        }
        
        // Build messages array for OpenAI format
        let messages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userMessage]
        ]
        
        // Build request body
        let requestBody = RequestBodyBuilder.buildChatCompletionBody(
            messages: messages,
            model: model,
            maxTokens: modelConfig.maxTokens,
            streaming: false
        )
        
        // Build headers
        var headers = providerConfig.additionalHeaders ?? [:]
        if let authHeader = providerConfig.authHeader,
           let authPrefix = providerConfig.authPrefix {
            headers[authHeader] = "\(authPrefix)\(apiKey)"
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
        guard let response = ResponseParser.parseResponse(data, provider: .openai) else {
            throw MemoryServiceError.parseError
        }
        
        return response.content
    }
}