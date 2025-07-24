import Foundation

class SuperjournalManager {
    static let shared = SuperjournalManager()
    private let superjournalPath = "superjournal"
    
    private init() {}
    
    func saveFullTurn(boss: String, persona: String, response: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        let dateString = formatter.string(from: Date())
        let filename = "FullTurn-\(dateString).md"
        
        let content = """
        ---
        timestamp: \(Date())
        persona: \(persona)
        ---
        
        Boss: \(boss)
        
        \(persona): \(response)
        """
        
        VaultWriter.shared.writeFile(content: content, to: "\(superjournalPath)/\(filename)")
    }
    
    func loadAllTurns() -> [ChatMessage] {
        let fileManager = FileManager.default
        let vaultPath = VaultPathProvider.vaultPath
        let fullSuperjournalPath = vaultPath + "/" + superjournalPath
        
        guard let urls = try? fileManager.contentsOfDirectory(
            at: URL(fileURLWithPath: fullSuperjournalPath),
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        var messages: [ChatMessage] = []
        
        for url in urls where url.lastPathComponent.hasPrefix("FullTurn-") {
            if let turnMessages = parseTurnFromFile(at: url.path) {
                messages.append(contentsOf: turnMessages)
            }
        }
        
        return messages.sorted { $0.timestamp < $1.timestamp }
    }
    
    private func parseTurnFromFile(at path: String) -> [ChatMessage]? {
        guard let content = try? String(contentsOfFile: path, encoding: .utf8) else {
            return nil
        }
        
        let lines = content.components(separatedBy: .newlines)
        var metadata: [String: String] = [:]
        var isInMetadata = false
        var bossInput = ""
        var personaResponse = ""
        var currentSection = ""
        
        for line in lines {
            if line == "---" {
                isInMetadata.toggle()
                continue
            }
            
            if isInMetadata {
                let parts = line.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
                if parts.count == 2 {
                    metadata[parts[0]] = parts[1]
                }
            } else if line.hasPrefix("Boss:") {
                currentSection = "boss"
                bossInput = String(line.dropFirst(5)).trimmingCharacters(in: .whitespaces)
            } else if let persona = metadata["persona"], line.hasPrefix("\(persona):") {
                currentSection = "persona"
                personaResponse = String(line.dropFirst(persona.count + 1)).trimmingCharacters(in: .whitespaces)
            } else {
                switch currentSection {
                case "boss":
                    if !line.isEmpty {
                        bossInput += "\n" + line
                    }
                case "persona":
                    if !line.isEmpty {
                        personaResponse += "\n" + line
                    }
                default:
                    break
                }
            }
        }
        
        guard let persona = metadata["persona"] else {
            return nil
        }
        
        return [
            ChatMessage(
                content: bossInput.trimmingCharacters(in: .whitespacesAndNewlines),
                author: VaultPersonaLoader.getBossLabel(),
                persona: nil
            ),
            ChatMessage(
                content: personaResponse.trimmingCharacters(in: .whitespacesAndNewlines),
                author: persona,
                persona: persona
            )
        ]
    }
}