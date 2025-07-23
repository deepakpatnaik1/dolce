//
//  ConversationOrchestrator.swift
//  Dolce
//
//  Pure conversation flow coordination
//
//  ATOMIC RESPONSIBILITY: Orchestrate conversation flow only
//  - Coordinate APIClient, ResponseParser, ConfigurationManager
//  - Manage conversation state and message flow
//  - Handle streaming and non-streaming responses
//  - Zero HTTP logic, zero parsing logic, zero configuration logic
//

import Foundation
import SwiftUI

@MainActor
class ConversationOrchestrator: ObservableObject {
    private let messageStore: MessageStore
    private let runtimeModelManager = RuntimeModelManager.shared
    
    init(messageStore: MessageStore) {
        self.messageStore = messageStore
    }
    
    // MARK: - Public Interface
    
    /// Send user message and orchestrate AI response
    func sendMessage(_ content: String, persona: String? = nil) async {
        // Add user message immediately
        let userMessage = ChatMessage(content: content, author: "User", persona: nil)
        messageStore.addMessage(userMessage)
        
        // Get AI response
        let activePersona = persona ?? PersonaSessionManager.shared.getCurrentPersona()
        await getAIResponse(for: content, persona: activePersona)
    }
    
    /// Send user message with attachments and orchestrate AI response
    func sendMessageWithAttachments(_ content: String, attachments: [DroppedFile], persona: String? = nil) async {
        // Add user message with attachments immediately
        let userMessage = ChatMessage(content: content, author: "User", persona: nil, attachments: attachments)
        messageStore.addMessage(userMessage)
        
        // Get AI response (content already includes processed file data)
        let activePersona = persona ?? PersonaSessionManager.shared.getCurrentPersona()
        await getAIResponse(for: content, persona: activePersona)
    }
    
    /// Check if conversation system is ready
    func isReady() -> Bool {
        return APIConfigurationProvider.isConfigurationValid()
    }
    
    /// Get system status message
    func getStatusMessage() -> String {
        return APIConfigurationProvider.getConfigurationStatus()
    }
    
    
    // MARK: - Private Orchestration
    
    /// Orchestrate AI response generation
    private func getAIResponse(for userMessage: String, persona: String) async {
        do {
            // Get configuration for selected model from RuntimeModelManager
            let selectedModelKey = runtimeModelManager.selectedModel
            let config = APIConfigurationProvider.getConfigForModel(selectedModelKey)
            
            guard let config = config else {
                addErrorMessage("No API configuration available for model: \(selectedModelKey)")
                return
            }
            
            // Start streaming response
            let streamingMessageId = messageStore.startStreamingMessage(
                author: "AI", 
                persona: persona
            )
            
            // Build request
            let request = try buildRequest(message: userMessage, config: config)
            
            // Handle OpenAI non-streaming response
            if config.provider == .openai {
                // Execute non-streaming request
                let (data, _) = try await HTTPExecutor.executeRequest(request)
                
                // Parse complete response
                if let parsedResponse = ResponseParser.parseResponse(data, provider: config.provider) {
                    messageStore.updateMessage(id: streamingMessageId, content: parsedResponse.content)
                } else {
                    messageStore.updateMessage(id: streamingMessageId, content: "Error: Could not parse response")
                }
            } else {
                // Execute streaming request for other providers
                let responseStream = try await HTTPExecutor.executeStreamingRequest(request)
                
                // Process response stream
                await processResponseStream(responseStream, config: config, messageId: streamingMessageId)
            }
            
        } catch {
            addErrorMessage("Error: \(error.localizedDescription)")
        }
    }
    
    /// Build API request using configuration
    private func buildRequest(message: String, config: APIConfiguration) throws -> URLRequest {
        // Build provider-specific request body
        let requestBody: [String: Any]
        switch config.provider {
        case .openai:
            requestBody = RequestBodyBuilder.buildOpenAIBody(
                message: message,
                model: config.model,
                maxTokens: config.maxTokens,
                streaming: false  // Temporarily disabled for debugging
            )
        case .anthropic:
            requestBody = RequestBodyBuilder.buildSingleMessageBody(
                message: message,
                model: config.model,
                maxTokens: config.maxTokens,
                streaming: true
            )
        @unknown default:
            requestBody = RequestBodyBuilder.buildSingleMessageBody(
                message: message,
                model: config.model,
                maxTokens: config.maxTokens,
                streaming: true
            )
        }
        
        return try HTTPRequestBuilder.buildRequest(
            baseURL: config.baseURL,
            endpoint: config.endpoint,
            apiKey: config.apiKey,
            requestBody: requestBody,
            headers: config.headers
        )
    }
    
    /// Process streaming response using ResponseParser
    private func processResponseStream(
        _ responseStream: AsyncThrowingStream<String, Error>,
        config: APIConfiguration,
        messageId: UUID
    ) async {
        var accumulatedContent = ""
        
        do {
            for try await line in responseStream {
                let chunk = ResponseParser.parseStreamingLine(line, provider: config.provider)
                
                if let content = chunk.content {
                    accumulatedContent += content
                    messageStore.updateMessage(id: messageId, content: accumulatedContent)
                }
                
                if chunk.isComplete {
                    break
                }
                
                if chunk.error != nil {
                    // Handle parsing error silently
                }
            }
        } catch {
            addErrorMessage("Streaming error: \(error.localizedDescription)")
        }
    }
    
    /// Add system error message
    private func addErrorMessage(_ message: String) {
        let errorMessage = ChatMessage(
            content: message,
            author: "System",
            persona: nil
        )
        messageStore.addMessage(errorMessage)
    }
}