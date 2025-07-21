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
    
    init(messageStore: MessageStore) {
        self.messageStore = messageStore
    }
    
    // MARK: - Public Interface
    
    /// Send user message and orchestrate AI response
    func sendMessage(_ content: String, persona: String = "claude") async {
        // Add user message immediately
        let userMessage = ChatMessage(content: content, author: "User", persona: nil)
        messageStore.addMessage(userMessage)
        
        // Get AI response
        await getAIResponse(for: content, persona: persona)
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
            // Get configuration
            guard let config = APIConfigurationProvider.getDefaultConfig() else {
                addErrorMessage("No API configuration available")
                return
            }
            
            // Start streaming response
            let streamingMessageId = messageStore.startStreamingMessage(
                author: "AI", 
                persona: persona
            )
            
            // Build request
            let request = try buildRequest(message: userMessage, config: config)
            
            // Execute streaming request
            let responseStream = try await HTTPExecutor.executeStreamingRequest(request)
            
            // Process response stream
            await processResponseStream(responseStream, config: config, messageId: streamingMessageId)
            
        } catch {
            addErrorMessage("Error: \(error.localizedDescription)")
        }
    }
    
    /// Build API request using configuration
    private func buildRequest(message: String, config: APIConfiguration) throws -> URLRequest {
        let requestBody = RequestBodyBuilder.buildSingleMessageBody(
            message: message,
            model: config.model,
            maxTokens: config.maxTokens
        )
        
        return try HTTPRequestBuilder.buildRequest(
            baseURL: config.baseURL,
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
                
                if let error = chunk.error {
                    print("Parsing error: \(error)")
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