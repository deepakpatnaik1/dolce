import Foundation

class VaultStateManager {
    static let shared = VaultStateManager()
    private let stateFile = PathConfiguration.currentPersonaPath
    private let vaultReader: VaultReading
    private let vaultWriter: VaultWriting
    
    // Keep private init for shared instance
    private init() {
        self.vaultReader = VaultReader.shared
        self.vaultWriter = VaultWriter.shared
    }
    
    // Add public init for dependency injection
    init(vaultReader: VaultReading = VaultReader.shared,
         vaultWriter: VaultWriting = VaultWriter.shared) {
        self.vaultReader = vaultReader
        self.vaultWriter = vaultWriter
    }
    
    func saveCurrentPersona(_ persona: String) {
        let content = persona.lowercased()
        vaultWriter.writeFile(content: content, to: stateFile)
    }
    
    func loadCurrentPersona() -> String? {
        return vaultReader.readFile(at: stateFile)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}