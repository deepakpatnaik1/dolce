import Foundation

class JournalManager {
    static let shared = JournalManager()
    private let journalPath = "journal"
    
    private init() {}
    
    func saveTrim(_ trim: MachineTrim) {
        let content = trim.toMarkdown()
        let filename = trim.filename()
        let path = "\(journalPath)/\(filename)"
        
        VaultWriter.shared.writeFile(content: content, to: path)
    }
    
    func loadRecentTrims(limit: Int = 10) -> [MachineTrim] {
        let fileManager = FileManager.default
        let vaultPath = VaultPathProvider.vaultPath
        let fullJournalPath = vaultPath + "/" + journalPath
        
        guard let urls = try? fileManager.contentsOfDirectory(
            at: URL(fileURLWithPath: fullJournalPath),
            includingPropertiesForKeys: [.contentModificationDateKey],
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        let trimFiles = urls.filter { $0.lastPathComponent.hasPrefix("Trim-") }
        
        let sortedFiles = trimFiles.sorted { url1, url2 in
            let date1 = (try? url1.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            let date2 = (try? url2.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? Date.distantPast
            return date1 > date2
        }
        
        return sortedFiles.prefix(limit).compactMap { url in
            parseTrimFromFile(at: url.path)
        }
    }
    
    func loadAllTrims() -> [MachineTrim] {
        let fileManager = FileManager.default
        let vaultPath = VaultPathProvider.vaultPath
        let fullJournalPath = vaultPath + "/" + journalPath
        
        guard let urls = try? fileManager.contentsOfDirectory(
            at: URL(fileURLWithPath: fullJournalPath),
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        return urls
            .filter { $0.lastPathComponent.hasPrefix("Trim-") }
            .compactMap { parseTrimFromFile(at: $0.path) }
            .sorted { $0.timestamp < $1.timestamp }
    }
    
    private func parseTrimFromFile(at path: String) -> MachineTrim? {
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
                    bossInput += "\n" + line
                case "persona":
                    personaResponse += "\n" + line
                default:
                    break
                }
            }
        }
        
        guard let timestampString = metadata["timestamp"],
              let persona = metadata["persona"],
              let topicHierarchyString = metadata["topic_hierarchy"],
              let keywordsString = metadata["keywords"],
              let dependenciesString = metadata["dependencies"],
              let sentiment = metadata["sentiment"] else {
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        guard let timestamp = formatter.date(from: timestampString) else {
            return nil
        }
        
        let topicHierarchy = topicHierarchyString.split(separator: ">").map { $0.trimmingCharacters(in: .whitespaces) }
        let keywords = keywordsString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        let dependencies = dependenciesString.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        return MachineTrim(
            timestamp: timestamp,
            persona: persona,
            bossInput: bossInput.trimmingCharacters(in: .whitespacesAndNewlines),
            personaResponse: personaResponse.trimmingCharacters(in: .whitespacesAndNewlines),
            topicHierarchy: topicHierarchy,
            keywords: keywords,
            dependencies: dependencies,
            sentiment: sentiment
        )
    }
}