//
//  LLMProviderFactory.swift
//  Aether
//
//  Factory for creating provider-specific memory services
//
//  ATOMIC RESPONSIBILITY: Create appropriate memory service based on provider
//  - Map provider names to service instances
//  - Return standardized interface for memory requests
//  - Zero business logic, zero state management
//

import Foundation

protocol LLMMemoryService {
    func sendRequest(systemPrompt: String, userMessage: String, model: String) async throws -> String
}

// Make our services conform to the protocol
extension AnthropicMemoryService: LLMMemoryService {}
extension OpenAIMemoryService: LLMMemoryService {}
extension FireworksMemoryService: LLMMemoryService {}

enum LLMProviderFactory {
    
    static func createService(for provider: String) throws -> LLMMemoryService {
        switch provider.lowercased() {
        case "anthropic":
            return AnthropicMemoryService()
        case "openai":
            return OpenAIMemoryService()
        case "fireworks":
            return FireworksMemoryService()
        default:
            throw LLMProviderError.unsupportedProvider(provider)
        }
    }
}

enum LLMProviderError: LocalizedError {
    case unsupportedProvider(String)
    
    var errorDescription: String? {
        switch self {
        case .unsupportedProvider(let provider):
            return "Unsupported provider: \(provider)"
        }
    }
}