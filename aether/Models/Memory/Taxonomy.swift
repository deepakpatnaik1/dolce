import Foundation

struct Taxonomy: Codable {
    struct Topic: Codable {
        let name: String
        var subcategories: [Subcategory]
    }
    
    struct Subcategory: Codable {
        let name: String
        var specifics: [String]
    }
    
    struct Context: Codable {
        let name: String
        let description: String
    }
    
    struct Dependency: Codable {
        let primary: String
        let secondary: String
        let relationship: String
    }
    
    struct Relationship: Codable {
        let topic1: String
        let topic2: String
        let relationType: String
    }
    
    var topics: [Topic]
    var contexts: [Context]
    var dependencies: [Dependency]
    var relationships: [Relationship]
}