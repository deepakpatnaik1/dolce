//
//  OpenAIService.swift
//  Dolce
//
//  OpenAI API integration service
//
//  ATOMIC RESPONSIBILITY: OpenAI API communication only
//  - Send chat completion requests
//  - Handle streaming responses
//  - Parse OpenAI-specific response format
//  - Zero business logic - pure API interaction
//

import Foundation

class OpenAIService {
    
    /// Send message to OpenAI and stream response
    static func sendMessage(
        _ message: String,
        model: String,
        apiKey: String,
        baseURL: String,
        maxTokens: Int
    ) async throws -> AsyncThrowingStream<String, Error> {
        
        // Build request
        let request = try buildRequest(
            message: message,
            model: model,
            apiKey: apiKey,
            baseURL: baseURL,
            maxTokens: maxTokens
        )
        
        // Execute streaming request
        return try await HTTPExecutor.executeStreamingRequest(request)
    }
    
    /// Build OpenAI-specific request
    private static func buildRequest(
        message: String,
        model: String,
        apiKey: String,
        baseURL: String,
        maxTokens: Int
    ) throws -> URLRequest {
        
        // Build OpenAI chat completions body
        let requestBody = RequestBodyBuilder.buildOpenAIBody(
            message: message,
            model: model,
            maxTokens: maxTokens,
            streaming: true
        )
        
        // Build request with OpenAI headers
        return try HTTPRequestBuilder.buildRequest(
            baseURL: baseURL,
            endpoint: "/v1/chat/completions",
            apiKey: apiKey,
            requestBody: requestBody,
            headers: [
                "Content-Type": "application/json",
                "Authorization": "Bearer \(apiKey)"
            ]
        )
    }
    
    /// Parse OpenAI streaming response line
    static func parseStreamingLine(_ line: String) -> StreamChunk {
        return ResponseParser.parseStreamingLine(line, provider: "openai")
    }
}