//
//  MemoryCoordinationService.swift
//  Aether
//
//  Atomic service for memory processing coordination
//
//  ATOMIC RESPONSIBILITY: Coordinate memory processing steps only
//  - Orchestrate bundle building, LLM calls, and response processing
//  - Save results to journal and superjournal
//  - Update taxonomy
//  - Zero state management, pure coordination logic
//

import Foundation

@MainActor
class MemoryCoordinationService {
    
    private let metadataParser = MetadataParser()
    
    /// Coordinate memory processing with all dependencies
    /// EXACT copy of logic from MemoryOrchestrator.processWithMemory
    func coordinateMemoryProcess(
        userInput: String,
        persona: String,
        bundleBuilder: OmniscientBundleBuilder,
        responseParser: ResponseParsing,
        journalManager: JournalManaging,
        superjournalManager: SuperjournalManaging,
        taxonomyEvolver: TaxonomyEvolver
    ) async throws -> String {
        // Validate bundle can be assembled
        _ = bundleBuilder.validateBundle(for: persona)
        // Silent validation - issues are handled gracefully by bundleBuilder
        
        // Step 1: Build omniscient bundle
        let bundle = bundleBuilder.buildBundle(for: persona, userMessage: userInput)
        let systemPrompt = bundle.systemPrompt()
        
        // Step 2: Get current model configuration
        let modelConfig = RuntimeModelManager.shared.selectedModel
        let components = modelConfig.split(separator: ":")
        guard components.count == 2 else {
            throw NSError(domain: "MemoryOrchestrator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid model configuration"])
        }
        
        let provider = String(components[0])
        let model = String(components[1])
        
        // Step 3: Send to appropriate LLM service with system prompt and user message
        let llmService = try LLMProviderFactory.createService(for: provider)
        let rawResponse = try await llmService.sendRequest(
            systemPrompt: systemPrompt,
            userMessage: userInput,
            model: model
        )
        
        // Step 4: Parse triple response
        let tripleResponse = responseParser.parse(rawResponse)
        
        // Step 5: Extract metadata from taxonomy analysis
        let metadata = metadataParser.parse(tripleResponse.taxonomyAnalysis)
        
        // Step 6: Create and save machine trim
        let trim = MachineTrim(
            timestamp: Date(),
            persona: persona,
            bossInput: userInput,
            personaResponse: tripleResponse.machineTrim,
            topicHierarchy: metadata.topicHierarchy,
            keywords: metadata.keywords,
            dependencies: metadata.dependencies,
            sentiment: metadata.sentiment
        )
        
        journalManager.saveTrim(trim)
        
        // Step 7: Save full turn to superjournal
        superjournalManager.saveFullTurn(
            boss: userInput,
            persona: persona,
            response: tripleResponse.mainResponse
        )
        
        // Step 8: Evolve taxonomy
        taxonomyEvolver.evolve(with: tripleResponse.taxonomyAnalysis)
        
        // Step 9: Return main response for display
        return tripleResponse.mainResponse
    }
    
    /// Coordinate streaming memory processing with all dependencies
    /// EXACT copy of logic from MemoryOrchestrator.processWithMemoryStreaming
    func coordinateMemoryProcessStreaming(
        userInput: String,
        persona: String,
        messageId: UUID,
        messageStore: MessageStore,
        bundleBuilder: OmniscientBundleBuilder,
        responseParser: ResponseParsing,
        journalManager: JournalManaging,
        superjournalManager: SuperjournalManaging,
        taxonomyEvolver: TaxonomyEvolver
    ) async throws {
        // Validate bundle can be assembled
        _ = bundleBuilder.validateBundle(for: persona)
        
        // Step 1: Build omniscient bundle
        let bundle = bundleBuilder.buildBundle(for: persona, userMessage: userInput)
        let systemPrompt = bundle.systemPrompt()
        
        // Step 2: Get current model configuration
        let modelConfig = RuntimeModelManager.shared.selectedModel
        let components = modelConfig.split(separator: ":")
        guard components.count == 2 else {
            throw NSError(domain: "MemoryOrchestrator", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid model configuration"])
        }
        
        let provider = String(components[0])
        let model = String(components[1])
        
        // Step 3: Send streaming request to appropriate LLM service
        let config = APIConfigurationProvider.getConfigForModel(modelConfig)!
        let request = try buildStreamingRequest(systemPrompt: systemPrompt, userMessage: userInput, model: model, provider: provider)
        
        // Step 4: Process streaming response
        let responseStream = try await HTTPExecutor.executeStreamingRequest(request)
        var accumulatedContent = ""
        
        for try await line in responseStream {
            let chunk = ResponseParser.parseStreamingLine(line, provider: config.provider)
            
            if let content = chunk.content {
                accumulatedContent += content
                
                
                // Extract and show only MAIN_RESPONSE section
                if let mainRange = accumulatedContent.range(of: "---MAIN_RESPONSE---") {
                    // Find the end of main response (or use end of accumulated content)
                    let afterMain = String(accumulatedContent[mainRange.upperBound...])
                    if let trimRange = afterMain.range(of: "---MACHINE_TRIM---") {
                        // Extract content between MAIN_RESPONSE and MACHINE_TRIM markers
                        let mainContent = String(afterMain[..<trimRange.lowerBound])
                        // Only trim newlines at the very start and end, preserve all Unicode including emojis
                        let trimmedContent = mainContent.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
                        
                        
                        messageStore.updateMessage(id: messageId, content: trimmedContent)
                    } else {
                        // Still streaming main response
                        let mainContent = afterMain
                        // Only trim newlines at the very start and end, preserve all Unicode including emojis
                        let trimmedContent = mainContent.trimmingCharacters(in: CharacterSet(charactersIn: "\n"))
                        messageStore.updateMessage(id: messageId, content: trimmedContent)
                    }
                }
            }
            
            if chunk.isComplete {
                break
            }
        }
        
        // Step 5: Parse complete triple response
        let tripleResponse = responseParser.parse(accumulatedContent)
        
        
        // Final update to ensure correct content is displayed
        messageStore.updateMessage(id: messageId, content: tripleResponse.mainResponse)
        
        // Step 6: Extract metadata from taxonomy analysis
        let metadata = metadataParser.parse(tripleResponse.taxonomyAnalysis)
        
        // Step 7: Create and save machine trim
        let trim = MachineTrim(
            timestamp: Date(),
            persona: persona,
            bossInput: userInput,
            personaResponse: tripleResponse.machineTrim,
            topicHierarchy: metadata.topicHierarchy,
            keywords: metadata.keywords,
            dependencies: metadata.dependencies,
            sentiment: metadata.sentiment
        )
        
        journalManager.saveTrim(trim)
        
        // Step 8: Save full turn to superjournal
        superjournalManager.saveFullTurn(
            boss: userInput,
            persona: persona,
            response: tripleResponse.mainResponse
        )
        
        // Step 9: Evolve taxonomy
        taxonomyEvolver.evolve(with: tripleResponse.taxonomyAnalysis)
    }
    
    /// Build streaming request - EXACT copy from MemoryOrchestrator
    private func buildStreamingRequest(systemPrompt: String, userMessage: String, model: String, provider: String) throws -> URLRequest {
        guard let providerConfig = ModelProvider.getProviderConfig(for: provider),
              let modelConfig = providerConfig.models.first(where: { $0.key == model }) else {
            throw MemoryServiceError.configurationNotFound
        }
        
        guard let apiKeyIdentifier = providerConfig.apiKeyIdentifier,
              let apiKey = APIKeyManager.getAPIKey(for: apiKeyIdentifier) else {
            throw MemoryServiceError.apiKeyNotFound
        }
        
        // Build request body based on provider
        let requestBody: [String: Any]
        if provider == "anthropic" {
            requestBody = RequestBodyBuilder.buildSingleMessageBody(
                message: userMessage,
                model: model,
                maxTokens: modelConfig.maxTokens,
                streaming: true,
                additionalParams: ["system": systemPrompt]
            )
        } else {
            // OpenAI/Fireworks format
            let messages: [[String: Any]] = [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": userMessage]
            ]
            requestBody = RequestBodyBuilder.buildChatCompletionBody(
                messages: messages,
                model: model,
                maxTokens: modelConfig.maxTokens,
                streaming: true
            )
        }
        
        // Build headers
        var headers = providerConfig.additionalHeaders ?? [:]
        if let authHeader = providerConfig.authHeader {
            if let authPrefix = providerConfig.authPrefix {
                headers[authHeader] = "\(authPrefix)\(apiKey)"
            } else {
                headers[authHeader] = apiKey
            }
        }
        
        return try HTTPRequestBuilder.buildRequest(
            baseURL: providerConfig.baseURL,
            endpoint: providerConfig.endpoint,
            apiKey: apiKey,
            requestBody: requestBody,
            headers: headers
        )
    }
}