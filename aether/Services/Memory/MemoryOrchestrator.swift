import Foundation

@MainActor
class MemoryOrchestrator {
    static let shared = MemoryOrchestrator()
    
    private let bundleBuilder: OmniscientBundleBuilder
    private let responseParser: ResponseParsing
    private let journalManager: JournalManaging
    private let superjournalManager: SuperjournalManaging
    private let taxonomyEvolver: TaxonomyEvolver
    private let coordinator = MemoryCoordinationService()
    
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
        responseParser: ResponseParsing = TripleResponseParser.shared,
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
        // DELEGATE to coordinator with same dependencies
        return try await coordinator.coordinateMemoryProcess(
            userInput: userInput,
            persona: persona,
            bundleBuilder: bundleBuilder,
            responseParser: responseParser,
            journalManager: journalManager,
            superjournalManager: superjournalManager,
            taxonomyEvolver: taxonomyEvolver
        )
    }
    
    func processWithMemoryStreaming(userInput: String, persona: String, messageId: UUID, messageStore: MessageStore) async throws {
        // DELEGATE to coordinator with same dependencies
        try await coordinator.coordinateMemoryProcessStreaming(
            userInput: userInput,
            persona: persona,
            messageId: messageId,
            messageStore: messageStore,
            bundleBuilder: bundleBuilder,
            responseParser: responseParser,
            journalManager: journalManager,
            superjournalManager: superjournalManager,
            taxonomyEvolver: taxonomyEvolver
        )
    }
    
}