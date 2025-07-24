//
//  ConversationRequestBuilder.swift
//  Dolce
//
//  Atomic service for building conversation API requests
//
//  ATOMIC RESPONSIBILITY: Build API requests for conversations only
//  - Handle provider-specific request body construction
//  - Delegate to appropriate RequestBodyBuilder methods
//  - Determine streaming settings per provider
//  - Zero HTTP logic, zero configuration fetching
//

import Foundation

struct ConversationRequestBuilder {
    
    /// Build API request for conversation
    func buildRequest(message: String, config: APIConfiguration) throws -> URLRequest {
        let requestBody = buildRequestBody(
            message: message,
            provider: config.provider,
            model: config.model,
            maxTokens: config.maxTokens
        )
        
        return try HTTPRequestBuilder.buildRequest(
            baseURL: config.baseURL,
            endpoint: config.endpoint,
            apiKey: config.apiKey,
            requestBody: requestBody,
            headers: config.headers
        )
    }
    
    /// Build provider-specific request body
    private func buildRequestBody(
        message: String,
        provider: APIProvider,
        model: String,
        maxTokens: Int
    ) -> [String: Any] {
        switch provider {
        case .openai:
            return RequestBodyBuilder.buildOpenAIBody(
                message: message,
                model: model,
                maxTokens: maxTokens,
                streaming: shouldStream(for: provider)
            )
        case .anthropic:
            return RequestBodyBuilder.buildSingleMessageBody(
                message: message,
                model: model,
                maxTokens: maxTokens,
                streaming: shouldStream(for: provider)
            )
        @unknown default:
            return RequestBodyBuilder.buildSingleMessageBody(
                message: message,
                model: model,
                maxTokens: maxTokens,
                streaming: true
            )
        }
    }
    
    /// Determine if provider should use streaming
    private func shouldStream(for provider: APIProvider) -> Bool {
        switch provider {
        case .openai, .anthropic:
            // Non-streaming for better markdown rendering
            return false
        @unknown default:
            return true
        }
    }
}