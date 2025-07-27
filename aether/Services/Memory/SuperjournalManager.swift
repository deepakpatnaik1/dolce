import Foundation

class SuperjournalManager: SuperjournalManaging {
    static let shared = SuperjournalManager()
    private let superjournalPath = "superjournal"
    private let vaultWriter: VaultWriting
    
    // Keep private init for shared instance
    private init() {
        self.vaultWriter = VaultWriter.shared
    }
    
    // Add public init for dependency injection
    init(vaultWriter: VaultWriting = VaultWriter.shared) {
        self.vaultWriter = vaultWriter
    }
    
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
        
        vaultWriter.writeFile(content: content, to: "\(superjournalPath)/\(filename)")
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
        
        guard let persona = metadata["persona"],
              let timestampString = metadata["timestamp"] else {
            return nil
        }
        
        // Parse timestamp from metadata
        let timestamp: Date
        if let parsedDate = ISO8601DateFormatter().date(from: timestampString) {
            timestamp = parsedDate
        } else {
            // Fallback: extract date from filename
            timestamp = extractDateFromFilename(path) ?? Date()
        }
        
        // Create messages with slightly offset timestamps to maintain order
        let bossTimestamp = timestamp
        let personaTimestamp = timestamp.addingTimeInterval(0.001) // 1ms later
        
        return [
            ChatMessage(
                id: UUID(),
                content: bossInput.trimmingCharacters(in: .whitespacesAndNewlines),
                author: VaultPersonaLoader.getBossLabel(),
                timestamp: bossTimestamp,
                persona: nil
            ),
            ChatMessage(
                id: UUID(),
                content: personaResponse.trimmingCharacters(in: .whitespacesAndNewlines),
                author: persona,
                timestamp: personaTimestamp,
                persona: persona
            )
        ]
    }
    
    private func extractDateFromFilename(_ path: String) -> Date? {
        let filename = URL(fileURLWithPath: path).lastPathComponent
        // Extract date from filename like "FullTurn-2025-07-24-1409.md"
        guard filename.hasPrefix("FullTurn-") else { return nil }
        
        let dateString = filename
            .replacingOccurrences(of: "FullTurn-", with: "")
            .replacingOccurrences(of: ".md", with: "")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        return formatter.date(from: dateString)
    }
}