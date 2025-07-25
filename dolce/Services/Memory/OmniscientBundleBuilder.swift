import Foundation

class OmniscientBundleBuilder {
    static let shared = OmniscientBundleBuilder()
    private let vaultReader: VaultReading
    private let journalManager: JournalManager
    
    // Keep private init for shared instance
    private init() {
        self.vaultReader = VaultReader.shared
        self.journalManager = JournalManager.shared
    }
    
    // Add public init for dependency injection
    init(vaultReader: VaultReading = VaultReader.shared,
         journalManager: JournalManager = JournalManager.shared) {
        self.vaultReader = vaultReader
        self.journalManager = journalManager
    }
    
    func buildBundle(for persona: String, userMessage: String) -> OmniscientBundle {
        let instructions = loadInstructions()
        let bossContext = loadBossContext()
        let personaContext = loadPersonaContext(for: persona)
        let toolsContext = loadToolsContext()
        let journalContext = loadJournalContext()
        let taxonomy = loadTaxonomy()
        
        return OmniscientBundle(
            instructions: instructions,
            bossContext: bossContext,
            personaContext: personaContext,
            toolsContext: toolsContext,
            journalContext: journalContext,
            taxonomy: taxonomy,
            userMessage: userMessage
        )
    }
    
    private func loadInstructions() -> String {
        return vaultReader.readFile(at: PathConfiguration.instructionsPath) ?? ""
    }
    
    private func loadBossContext() -> String {
        return loadAllMarkdownFiles(from: PathConfiguration.bossPath, sectionName: "BOSS")
    }
    
    private func loadPersonaContext(for persona: String) -> String {
        // Use capitalized persona name for directory
        let personaFolderPath = PathConfiguration.personaFolderPath(for: persona)
        return loadAllMarkdownFiles(from: personaFolderPath, sectionName: "PERSONA")
    }
    
    private func loadToolsContext() -> String {
        return loadAllMarkdownFiles(from: PathConfiguration.toolsPath, sectionName: "TOOLS")
    }
    
    private func loadJournalContext() -> String {
        let recentTrims = journalManager.loadRecentTrims(limit: 20)
        
        if recentTrims.isEmpty {
            return "No previous conversations in journal."
        }
        
        return recentTrims.map { trim in
            trim.toMarkdown()
        }.joined(separator: "\n\n---\n\n")
    }
    
    private func loadTaxonomy() -> String {
        guard let taxonomy = vaultReader.readFile(at: PathConfiguration.taxonomyPath) else {
            return "{}"
        }
        return taxonomy
    }
    
    // MARK: - File Loading Utilities
    
    /// Load all .md files from a directory and concatenate with file markers
    private func loadAllMarkdownFiles(from relativePath: String, sectionName: String) -> String {
        let fullPath = VaultPathProvider.vaultPath + "/" + relativePath
        
        guard FileManager.default.fileExists(atPath: fullPath) else {
            // Some folders may not exist yet - return empty rather than error
            return ""
        }
        
        let fileManager = FileManager.default
        guard let urls = try? fileManager.contentsOfDirectory(
            at: URL(fileURLWithPath: fullPath),
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return ""
        }
        
        let markdownFiles = urls.filter { $0.pathExtension == "md" }.sorted { $0.lastPathComponent < $1.lastPathComponent }
        
        guard !markdownFiles.isEmpty else {
            return ""
        }
        
        var allContent: [String] = []
        
        for url in markdownFiles {
            let fileName = url.lastPathComponent
            do {
                let content = try String(contentsOf: url, encoding: .utf8)
                allContent.append("--- FILE: \(fileName) ---")
                allContent.append(content)
                allContent.append("") // Empty line separator
            } catch {
                // Could not read file - continue with other files
            }
        }
        
        return allContent.joined(separator: "\n")
    }
    
    // MARK: - Bundle Validation
    
    /// Validate that bundle can be assembled for persona
    func validateBundle(for persona: String) -> [String] {
        var issues: [String] = []
        
        // Check instructions
        let instructionsPath = VaultPathProvider.vaultPath + "/" + PathConfiguration.instructionsPath
        if !FileManager.default.fileExists(atPath: instructionsPath) {
            issues.append("Missing \(PathConfiguration.instructionsFile)")
        }
        
        // Check persona exists
        let personaFolderPath = VaultPathProvider.vaultPath + "/" + PathConfiguration.personaFolderPath(for: persona)
        if !FileManager.default.fileExists(atPath: personaFolderPath) {
            issues.append("Persona folder not found: \(persona)")
        }
        
        // Check persona has content
        let personaFilePath = VaultPathProvider.vaultPath + "/" + PathConfiguration.personaFilePath(for: persona)
        if !FileManager.default.fileExists(atPath: personaFilePath) {
            let personaName = persona.prefix(1).uppercased() + persona.dropFirst()
            issues.append("Persona file not found: \(personaName)\(PathConfiguration.markdownExtension)")
        }
        
        return issues
    }
}