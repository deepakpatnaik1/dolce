import Foundation

class TaxonomyEvolver {
    static let shared = TaxonomyEvolver()
    private let taxonomyPath = "playbook/tools/taxonomy.json"
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
    
    func evolve(with analysis: String) {
        guard var taxonomy = loadCurrentTaxonomy() else {
            // Failed to load current taxonomy - will create new one
            return
        }
        
        // Parse the analysis to extract new topics, contexts, etc.
        let lines = analysis.components(separatedBy: .newlines)
        
        for line in lines {
            if line.contains("NEW_TOPIC:") {
                if let topic = extractValue(from: line, prefix: "NEW_TOPIC:") {
                    addTopicIfNeeded(&taxonomy, topic: topic)
                }
            } else if line.contains("NEW_CONTEXT:") {
                if let context = extractValue(from: line, prefix: "NEW_CONTEXT:") {
                    addContextIfNeeded(&taxonomy, context: context)
                }
            } else if line.contains("NEW_DEPENDENCY:") {
                if let dependency = extractValue(from: line, prefix: "NEW_DEPENDENCY:") {
                    addDependencyIfNeeded(&taxonomy, dependency: dependency)
                }
            }
        }
        
        saveTaxonomy(taxonomy)
    }
    
    func loadCurrentTaxonomy() -> Taxonomy? {
        return vaultReader.readJSON(at: taxonomyPath, as: Taxonomy.self)
    }
    
    func saveTaxonomy(_ taxonomy: Taxonomy) {
        vaultWriter.writeJSON(taxonomy, to: taxonomyPath)
    }
    
    private func extractValue(from line: String, prefix: String) -> String? {
        guard line.contains(prefix) else { return nil }
        let value = line.replacingOccurrences(of: prefix, with: "").trimmingCharacters(in: .whitespaces)
        return value.isEmpty ? nil : value
    }
    
    private func addTopicIfNeeded(_ taxonomy: inout Taxonomy, topic: String) {
        let components = topic.split(separator: "/").map { String($0) }
        guard components.count >= 2 else { return }
        
        let topicName = components[0]
        let subcategoryName = components[1]
        let specific = components.count > 2 ? components[2] : ""
        
        if let topicIndex = taxonomy.topics.firstIndex(where: { $0.name == topicName }) {
            if let subcategoryIndex = taxonomy.topics[topicIndex].subcategories.firstIndex(where: { $0.name == subcategoryName }) {
                if !specific.isEmpty && !taxonomy.topics[topicIndex].subcategories[subcategoryIndex].specifics.contains(specific) {
                    taxonomy.topics[topicIndex].subcategories[subcategoryIndex].specifics.append(specific)
                }
            } else {
                let newSubcategory = Taxonomy.Subcategory(
                    name: subcategoryName,
                    specifics: specific.isEmpty ? [] : [specific]
                )
                taxonomy.topics[topicIndex].subcategories.append(newSubcategory)
            }
        } else {
            let newTopic = Taxonomy.Topic(
                name: topicName,
                subcategories: [
                    Taxonomy.Subcategory(
                        name: subcategoryName,
                        specifics: specific.isEmpty ? [] : [specific]
                    )
                ]
            )
            taxonomy.topics.append(newTopic)
        }
    }
    
    private func addContextIfNeeded(_ taxonomy: inout Taxonomy, context: String) {
        let parts = context.split(separator: ":", maxSplits: 1).map { String($0) }
        guard parts.count == 2 else { return }
        
        let name = parts[0].trimmingCharacters(in: .whitespaces)
        let description = parts[1].trimmingCharacters(in: .whitespaces)
        
        if !taxonomy.contexts.contains(where: { $0.name == name }) {
            taxonomy.contexts.append(Taxonomy.Context(name: name, description: description))
        }
    }
    
    private func addDependencyIfNeeded(_ taxonomy: inout Taxonomy, dependency: String) {
        let parts = dependency.split(separator: "->").map { String($0).trimmingCharacters(in: .whitespaces) }
        guard parts.count >= 2 else { return }
        
        let primary = parts[0]
        let secondary = parts[1]
        let relationship = parts.count > 2 ? parts[2] : "depends on"
        
        if !taxonomy.dependencies.contains(where: { $0.primary == primary && $0.secondary == secondary }) {
            taxonomy.dependencies.append(
                Taxonomy.Dependency(primary: primary, secondary: secondary, relationship: relationship)
            )
        }
    }
}