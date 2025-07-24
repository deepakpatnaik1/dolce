import Foundation

@MainActor
class MemoryOrchestrator {
    static let shared = MemoryOrchestrator()
    
    private let bundleBuilder = OmniscientBundleBuilder.shared
    private let responseParser = TripleResponseParser.shared
    private let journalManager = JournalManager.shared
    private let superjournalManager = SuperjournalManager.shared
    private let taxonomyEvolver = TaxonomyEvolver.shared
    
    private init() {}
    
    func processWithMemory(userInput: String, persona: String) async throws -> String {
        // Validate bundle can be assembled
        let validationIssues = bundleBuilder.validateBundle(for: persona)
        if !validationIssues.isEmpty {
            print("[MemoryOrchestrator] ⚠️ Bundle validation issues: \(validationIssues.joined(separator: ", "))")
        }
        
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
        let rawResponse = try await sendToLLM(
            systemPrompt: systemPrompt,
            userMessage: userInput,
            provider: provider,
            model: model
        )
        
        
        // Step 4: Parse triple response
        let tripleResponse = responseParser.parse(rawResponse)
        print("[MemoryOrchestrator] Parsed response - Main response length: \(tripleResponse.mainResponse.count) chars")
        
        // Step 5: Extract metadata from taxonomy analysis
        let metadata = parseMetadata(from: tripleResponse.taxonomyAnalysis)
        
        // Step 6: Create and save machine trim
        let trim = MachineTrim(
            timestamp: Date(),
            persona: persona,
            bossInput: userInput,
            personaResponse: tripleResponse.mainResponse,
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
    
    private func sendToLLM(systemPrompt: String, userMessage: String, provider: String, model: String) async throws -> String {
        switch provider.lowercased() {
        case "anthropic":
            return try await sendToAnthropic(systemPrompt: systemPrompt, userMessage: userMessage, model: model)
        case "openai":
            return try await sendToOpenAI(systemPrompt: systemPrompt, userMessage: userMessage, model: model)
        case "fireworks":
            return try await sendToFireworks(systemPrompt: systemPrompt, userMessage: userMessage, model: model)
        default:
            throw NSError(domain: "MemoryOrchestrator", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unsupported provider: \(provider)"])
        }
    }
    
    private func sendToAnthropic(systemPrompt: String, userMessage: String, model: String) async throws -> String {
        guard let apiKey = APIKeyManager.getAPIKey(for: "ANTHROPIC_API_KEY") else {
            throw NSError(domain: "MemoryOrchestrator", code: 4, userInfo: [NSLocalizedDescriptionKey: "No API key for Anthropic"])
        }
        
        let requestBody = RequestBodyBuilder.buildSingleMessageBody(
            message: userMessage,
            model: model,
            maxTokens: 4096,
            streaming: false,
            additionalParams: ["system": systemPrompt]
        )
        
        let request = try HTTPRequestBuilder.buildRequest(
            baseURL: "https://api.anthropic.com",
            endpoint: "/v1/messages",
            apiKey: apiKey,
            requestBody: requestBody,
            headers: [
                "anthropic-version": "2023-06-01",
                "x-api-key": apiKey
            ]
        )
        
        let (data, _) = try await HTTPExecutor.executeRequest(request)
        
        if let response = ResponseParser.parseResponse(data, provider: .anthropic) {
            return response.content
        } else {
            throw NSError(domain: "MemoryOrchestrator", code: 5, userInfo: [NSLocalizedDescriptionKey: "Failed to parse Anthropic response"])
        }
    }
    
    private func sendToOpenAI(systemPrompt: String, userMessage: String, model: String) async throws -> String {
        guard let apiKey = APIKeyManager.getAPIKey(for: "OPENAI_API_KEY") else {
            throw NSError(domain: "MemoryOrchestrator", code: 3, userInfo: [NSLocalizedDescriptionKey: "No API key for OpenAI"])
        }
        
        // OpenAI needs system prompt as a separate message
        let messages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userMessage]
        ]
        
        let requestBody = RequestBodyBuilder.buildChatCompletionBody(
            messages: messages,
            model: model,
            maxTokens: 4096,
            streaming: false
        )
        
        let request = try HTTPRequestBuilder.buildRequest(
            baseURL: "https://api.openai.com",
            endpoint: "/v1/chat/completions",
            apiKey: apiKey,
            requestBody: requestBody,
            headers: [
                "Authorization": "Bearer \(apiKey)"
            ]
        )
        
        let (data, _) = try await HTTPExecutor.executeRequest(request)
        
        if let response = ResponseParser.parseResponse(data, provider: .openai) {
            return response.content
        } else {
            throw NSError(domain: "MemoryOrchestrator", code: 6, userInfo: [NSLocalizedDescriptionKey: "Failed to parse OpenAI response"])
        }
    }
    
    private func sendToFireworks(systemPrompt: String, userMessage: String, model: String) async throws -> String {
        guard let apiKey = APIKeyManager.getAPIKey(for: "FIREWORKS_API_KEY") else {
            throw NSError(domain: "MemoryOrchestrator", code: 7, userInfo: [NSLocalizedDescriptionKey: "No API key for Fireworks"])
        }
        
        // Fireworks uses OpenAI-compatible format with system messages
        let messages: [[String: Any]] = [
            ["role": "system", "content": systemPrompt],
            ["role": "user", "content": userMessage]
        ]
        
        let requestBody = RequestBodyBuilder.buildChatCompletionBody(
            messages: messages,
            model: model,
            maxTokens: 4096,
            streaming: false
        )
        
        let request = try HTTPRequestBuilder.buildRequest(
            baseURL: "https://api.fireworks.ai",
            endpoint: "/inference/v1/chat/completions",
            apiKey: apiKey,
            requestBody: requestBody,
            headers: [
                "Authorization": "Bearer \(apiKey)"
            ]
        )
        
        let (data, _) = try await HTTPExecutor.executeRequest(request)
        
        // Fireworks uses OpenAI-compatible format
        if let response = ResponseParser.parseResponse(data, provider: .openai) {
            return response.content
        } else {
            throw NSError(domain: "MemoryOrchestrator", code: 8, userInfo: [NSLocalizedDescriptionKey: "Failed to parse Fireworks response"])
        }
    }
    
    private func parseMetadata(from analysis: String) -> (topicHierarchy: [String], keywords: [String], dependencies: [String], sentiment: String) {
        var topicHierarchy: [String] = []
        var keywords: [String] = []
        var dependencies: [String] = []
        var sentiment = "neutral"
        
        let lines = analysis.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix("TOPIC:") {
                let topic = trimmedLine.replacingOccurrences(of: "TOPIC:", with: "").trimmingCharacters(in: .whitespaces)
                topicHierarchy = topic.split(separator: "/").map { String($0).trimmingCharacters(in: .whitespaces) }
            } else if trimmedLine.hasPrefix("KEYWORDS:") {
                let keywordString = trimmedLine.replacingOccurrences(of: "KEYWORDS:", with: "").trimmingCharacters(in: .whitespaces)
                keywords = keywordString.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            } else if trimmedLine.hasPrefix("DEPENDENCIES:") {
                let depString = trimmedLine.replacingOccurrences(of: "DEPENDENCIES:", with: "").trimmingCharacters(in: .whitespaces)
                dependencies = depString.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            } else if trimmedLine.hasPrefix("SENTIMENT:") {
                sentiment = trimmedLine.replacingOccurrences(of: "SENTIMENT:", with: "").trimmingCharacters(in: .whitespaces).lowercased()
            }
        }
        
        // Provide defaults if not found
        if topicHierarchy.isEmpty {
            topicHierarchy = ["general", "conversation"]
        }
        if keywords.isEmpty {
            keywords = ["untagged"]
        }
        
        return (topicHierarchy, keywords, dependencies, sentiment)
    }
}