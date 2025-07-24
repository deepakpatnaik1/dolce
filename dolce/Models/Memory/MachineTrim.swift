import Foundation

struct MachineTrim: Codable {
    let timestamp: Date
    let persona: String
    let bossInput: String
    let personaResponse: String
    let topicHierarchy: [String]
    let keywords: [String]
    let dependencies: [String]
    let sentiment: String
    
    func toMarkdown() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let timestampString = formatter.string(from: timestamp)
        
        return """
        ---
        timestamp: \(timestampString)
        persona: \(persona)
        topic_hierarchy: \(topicHierarchy.joined(separator: " > "))
        keywords: \(keywords.joined(separator: ", "))
        dependencies: \(dependencies.joined(separator: ", "))
        sentiment: \(sentiment)
        ---
        
        Boss: \(bossInput)
        
        \(persona): \(personaResponse)
        """
    }
    
    func filename() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        let dateString = formatter.string(from: timestamp)
        return "Trim-\(dateString).md"
    }
}