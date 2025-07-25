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
    private let runtimeModelManager: RuntimeModelManager
    private let personaSessionManager: PersonaSessionManager
    private let memoryOrchestrator: MemoryOrchestrator
    private let requestBuilder = ConversationRequestBuilder()
    
    init(
        messageStore: MessageStore,
        runtimeModelManager: RuntimeModelManager,
        personaSessionManager: PersonaSessionManager,
        memoryOrchestrator: MemoryOrchestrator
    ) {
        self.messageStore = messageStore
        self.runtimeModelManager = runtimeModelManager
        self.personaSessionManager = personaSessionManager
        self.memoryOrchestrator = memoryOrchestrator
    }
    
    // MARK: - Public Interface
    
    /// Send user message and orchestrate AI response
    func sendMessage(_ content: String, persona: String? = nil) async {
        // Add user message immediately
        let userMessage = MessageFactory.createUserMessage(content: content)
        messageStore.addMessage(userMessage)
        
        // Get AI response
        let activePersona = persona ?? personaSessionManager.getCurrentPersona()
        await getAIResponse(for: content, persona: activePersona)
    }
    
    /// Send user message with attachments and orchestrate AI response
    func sendMessageWithAttachments(_ content: String, attachments: [DroppedFile], persona: String? = nil) async {
        // Add user message with attachments immediately
        let userMessage = MessageFactory.createUserMessage(content: content, attachments: attachments)
        messageStore.addMessage(userMessage)
        
        // Get AI response (content already includes processed file data)
        let activePersona = persona ?? personaSessionManager.getCurrentPersona()
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
            // Check if memory system is enabled
            if AppConfigurationLoader.isMemorySystemEnabled {
                // Use memory system for processing
                let response = try await memoryOrchestrator.processWithMemory(
                    userInput: userMessage,
                    persona: persona
                )
                
                // Add the response to message store
                let aiMessage = MessageFactory.createAIMessage(
                    content: response,
                    persona: persona
                )
                messageStore.addMessage(aiMessage)
            } else {
                // Use original non-memory flow
                await getAIResponseOriginal(for: userMessage, persona: persona)
            }
        } catch {
            addErrorMessage("Error: \(error.localizedDescription)")
        }
    }
    
    /// Original AI response generation (without memory)
    private func getAIResponseOriginal(for userMessage: String, persona: String) async {
        do {
            // Get configuration for selected model from RuntimeModelManager
            let selectedModelKey = runtimeModelManager.selectedModel
            let config = APIConfigurationProvider.getConfigForModel(selectedModelKey)
            
            guard let config = config else {
                addErrorMessage("No API configuration available for model: \(selectedModelKey)")
                return
            }
            
            // Start streaming response
            let streamingMessage = MessageFactory.createStreamingAIMessage(persona: persona)
            messageStore.addMessage(streamingMessage)
            let streamingMessageId = streamingMessage.id
            
            // Build request
            let request = try requestBuilder.buildRequest(message: userMessage, config: config)
            
            // Always use non-streaming for all providers
            let (data, _) = try await HTTPExecutor.executeRequest(request)
            
            // Parse complete response
            if let parsedResponse = ResponseParser.parseResponse(data, provider: config.provider) {
                messageStore.updateMessage(id: streamingMessageId, content: parsedResponse.content)
            } else {
                messageStore.updateMessage(id: streamingMessageId, content: "Error: Could not parse response")
            }
            
        } catch {
            addErrorMessage("Error: \(error.localizedDescription)")
        }
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
        let errorMessage = MessageFactory.createSystemMessage(content: message)
        messageStore.addMessage(errorMessage)
    }
}