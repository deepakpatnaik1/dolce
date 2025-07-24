import Foundation

class VaultStateManager {
    static let shared = VaultStateManager()
    private let stateFile = "playbook/tools/currentPersona.md"
    private let scrollStateFile = ".app-state/scrollPosition.json"
    
    private init() {}
    
    func saveCurrentPersona(_ persona: String) {
        let content = persona.lowercased()
        VaultWriter.shared.writeFile(content: content, to: stateFile)
    }
    
    func loadCurrentPersona() -> String? {
        return VaultReader.shared.readFile(at: stateFile)?
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    func saveScrollPosition(_ position: CGFloat) {
        let state = ["scrollPosition": position]
        VaultWriter.shared.writeJSON(state, to: scrollStateFile)
    }
    
    func loadScrollPosition() -> CGFloat? {
        let state = VaultReader.shared.readJSON(at: scrollStateFile, as: [String: CGFloat].self)
        return state?["scrollPosition"]
    }
}