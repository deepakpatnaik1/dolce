//
//  RequestBodyBuilder.swift
//  Dolce
//
//  Atomic request body builder
//
//  ATOMIC RESPONSIBILITY: Build request bodies only
//  - Construct JSON request bodies for LLM APIs
//  - Handle different message formats
//  - Add parameters and options
//  - Zero HTTP logic, zero execution, zero parsing
//

import Foundation

struct RequestBodyBuilder {
    
    /// Build standard chat completion request body
    static func buildChatCompletionBody(
        messages: [[String: Any]],
        model: String,
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        streaming: Bool = false,
        additionalParams: [String: Any] = [:]
    ) -> [String: Any] {
        
        var body: [String: Any] = [
            "messages": messages,
            "model": model,
            "stream": streaming
        ]
        
        if let maxTokens = maxTokens {
            body["max_tokens"] = maxTokens
        }
        
        if let temperature = temperature {
            body["temperature"] = temperature
        }
        
        // Add any additional parameters
        for (key, value) in additionalParams {
            body[key] = value
        }
        
        return body
    }
    
    /// Build single message request body (convenience)
    static func buildSingleMessageBody(
        message: String,
        model: String,
        role: String = "user",
        maxTokens: Int? = nil,
        temperature: Double? = nil,
        streaming: Bool = false,
        additionalParams: [String: Any] = [:]
    ) -> [String: Any] {
        
        let messages = [["role": role, "content": message]]
        
        return buildChatCompletionBody(
            messages: messages,
            model: model,
            maxTokens: maxTokens,
            temperature: temperature,
            streaming: streaming,
            additionalParams: additionalParams
        )
    }
    
    /// Build OpenAI-specific request body
    static func buildOpenAIBody(
        message: String,
        model: String,
        maxTokens: Int,
        streaming: Bool = true
    ) -> [String: Any] {
        
        let messages: [[String: Any]] = [
            [
                "role": "user",
                "content": message
            ]
        ]
        
        return [
            "model": model,
            "messages": messages,
            "max_tokens": maxTokens,
            "stream": streaming,
            "temperature": 0.7
        ]
    }
}