//
//  ResponseParser.swift
//  Dolce
//
//  Pure response parsing for LLM API responses
//
//  ATOMIC RESPONSIBILITY: Parse raw API responses only
//  - Extract content from streaming/non-streaming responses  
//  - Handle different API response formats (OpenAI, Anthropic, etc.)
//  - Convert raw JSON/text to structured data
//  - Zero HTTP logic, zero UI logic, zero orchestration
//

import Foundation

// MARK: - Response Data Models

struct ParsedResponse {
    let content: String
    let isComplete: Bool
    let metadata: [String: Any]?
}

struct StreamingChunk {
    let content: String?
    let isComplete: Bool
    let error: String?
}

// MARK: - Response Parser

struct ResponseParser {
    
    // MARK: - Anthropic Response Parsing
    
    /// Parse Anthropic streaming response line
    static func parseAnthropicStreamingLine(_ line: String) -> StreamingChunk {
        // Handle Anthropic's Server-Sent Events format
        if line.hasPrefix("data: ") {
            let jsonString = String(line.dropFirst(6))
            
            // Handle end-of-stream marker
            if jsonString.trimmingCharacters(in: .whitespaces) == "[DONE]" {
                return StreamingChunk(content: nil, isComplete: true, error: nil)
            }
            
            // Parse JSON chunk
            guard let data = jsonString.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return StreamingChunk(content: nil, isComplete: false, error: "Invalid JSON")
            }
            
            // Extract content from delta
            if let delta = json["delta"] as? [String: Any],
               let text = delta["text"] as? String {
                return StreamingChunk(content: text, isComplete: false, error: nil)
            }
            
            // Check for completion
            if let type = json["type"] as? String, type == "message_stop" {
                return StreamingChunk(content: nil, isComplete: true, error: nil)
            }
        }
        
        return StreamingChunk(content: nil, isComplete: false, error: nil)
    }
    
    /// Parse complete Anthropic response
    static func parseAnthropicResponse(_ data: Data) -> ParsedResponse? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["content"] as? [[String: Any]],
              let firstContent = content.first,
              let text = firstContent["text"] as? String else {
            return nil
        }
        
        return ParsedResponse(content: text, isComplete: true, metadata: json)
    }
    
    // MARK: - OpenAI Response Parsing
    
    /// Parse OpenAI streaming response line
    static func parseOpenAIStreamingLine(_ line: String) -> StreamingChunk {
        // Handle OpenAI's Server-Sent Events format
        if line.hasPrefix("data: ") {
            let jsonString = String(line.dropFirst(6))
            
            // Handle end-of-stream marker
            if jsonString.trimmingCharacters(in: .whitespaces) == "[DONE]" {
                return StreamingChunk(content: nil, isComplete: true, error: nil)
            }
            
            // Parse JSON chunk
            guard let data = jsonString.data(using: .utf8),
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                return StreamingChunk(content: nil, isComplete: false, error: "Invalid JSON")
            }
            
            // Extract content from choices (handle null content gracefully)
            if let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let delta = firstChoice["delta"] as? [String: Any] {
                let content = delta["content"] as? String
                if content != nil {
                    return StreamingChunk(content: content, isComplete: false, error: nil)
                }
            }
            
            // Check for completion
            if let choices = json["choices"] as? [[String: Any]],
               let firstChoice = choices.first,
               let _ = firstChoice["finish_reason"] as? String {
                return StreamingChunk(content: nil, isComplete: true, error: nil)
            }
        }
        
        return StreamingChunk(content: nil, isComplete: false, error: nil)
    }
    
    /// Parse complete OpenAI response
    static func parseOpenAIResponse(_ data: Data) -> ParsedResponse? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            return nil
        }
        
        return ParsedResponse(content: content, isComplete: true, metadata: json)
    }
    
    // MARK: - Local Model Parsing
    
    private static func parseLocalStreamingLine(_ line: String) -> StreamingChunk {
        // For now, return a placeholder - local models need different handling
        return StreamingChunk(
            content: "Local model support not implemented yet",
            isComplete: true,
            error: nil
        )
    }
    
    private static func parseLocalResponse(_ data: Data) -> ParsedResponse? {
        // For now, return a placeholder - local models need different handling
        return ParsedResponse(
            content: "Local model support not implemented yet",
            isComplete: true,
            metadata: nil
        )
    }
    
    // MARK: - Generic Parsing
    
    /// Parse streaming line based on provider
    static func parseStreamingLine(_ line: String, provider: APIProvider) -> StreamingChunk {
        switch provider {
        case .anthropic:
            return parseAnthropicStreamingLine(line)
        case .openai:
            return parseOpenAIStreamingLine(line)
        case .fireworks:
            return parseOpenAIStreamingLine(line) // Fireworks uses OpenAI format
        case .ollama:
            return parseOpenAIStreamingLine(line) // Ollama uses OpenAI-compatible format
        case .local:
            return parseLocalStreamingLine(line) // Local models need special handling
        }
    }
    
    /// Parse complete response based on provider
    static func parseResponse(_ data: Data, provider: APIProvider) -> ParsedResponse? {
        switch provider {
        case .anthropic:
            return parseAnthropicResponse(data)
        case .openai:
            return parseOpenAIResponse(data)
        case .fireworks:
            return parseOpenAIResponse(data) // Fireworks uses OpenAI format
        case .ollama:
            return parseOpenAIResponse(data) // Ollama uses OpenAI-compatible format
        case .local:
            return parseLocalResponse(data) // Local models need special handling
        }
    }
}

// MARK: - Supporting Types
