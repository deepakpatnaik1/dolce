import Foundation

@MainActor
class MemoryOrchestrator {
    static let shared = MemoryOrchestrator()
    
    private let bundleBuilder: OmniscientBundleBuilder
    private let responseParser: TripleResponseParser
    private let journalManager: JournalManaging
    private let superjournalManager: SuperjournalManaging
    private let taxonomyEvolver: TaxonomyEvolver
    private let metadataParser = MetadataParser()
    
    // Keep private init for shared instance
    private init() {
        self.bundleBuilder = OmniscientBundleBuilder.shared
        self.responseParser = TripleResponseParser.shared
        self.journalManager = JournalManager.shared
        self.superjournalManager = SuperjournalManager.shared
        self.taxonomyEvolver = TaxonomyEvolver.shared
    }
    
    // Add public init for dependency injection
    init(
        bundleBuilder: OmniscientBundleBuilder = .shared,
        responseParser: TripleResponseParser = .shared,
        journalManager: JournalManaging = JournalManager.shared,
        superjournalManager: SuperjournalManaging = SuperjournalManager.shared,
        taxonomyEvolver: TaxonomyEvolver = .shared
    ) {
        self.bundleBuilder = bundleBuilder
        self.responseParser = responseParser
        self.journalManager = journalManager
        self.superjournalManager = superjournalManager
        self.taxonomyEvolver = taxonomyEvolver
    }
    
    func processWithMemory(userInput: String, persona: String) async throws -> String {
        // Validate bundle can be assembled
        let validationIssues = bundleBuilder.validateBundle(for: persona)
        if !validationIssues.isEmpty {
            #if DEBUG
            print("[MemoryOrchestrator] ⚠️ Bundle validation issues: \(validationIssues.joined(separator: ", "))")
            #endif
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
        let llmService = try LLMProviderFactory.createService(for: provider)
        let rawResponse = try await llmService.sendRequest(
            systemPrompt: systemPrompt,
            userMessage: userInput,
            model: model
        )
        
        
        #if DEBUG
        // Log the raw response for debugging
        print("[MemoryOrchestrator] ===== RAW LLM RESPONSE =====")
        print(rawResponse)
        print("[MemoryOrchestrator] ===== END RAW RESPONSE =====")
        #endif
        
        // Step 4: Parse triple response
        let tripleResponse = responseParser.parse(rawResponse)
        
        #if DEBUG
        // Log parsed sections for debugging
        print("[MemoryOrchestrator] ===== PARSED SECTIONS =====")
        print("TAXONOMY_ANALYSIS length: \(tripleResponse.taxonomyAnalysis.count) chars")
        print("MAIN_RESPONSE preview: \(String(tripleResponse.mainResponse.prefix(200)))")
        print("MACHINE_TRIM preview: \(String(tripleResponse.machineTrim.prefix(200)))")
        print("[MemoryOrchestrator] ===== END PARSED =====")
        print("[MemoryOrchestrator] Parsed response - Main response length: \(tripleResponse.mainResponse.count) chars")
        #endif
        
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
}