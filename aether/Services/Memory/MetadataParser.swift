//
//  MetadataParser.swift
//  Aether
//
//  Atomic parser for taxonomy analysis metadata
//
//  ATOMIC RESPONSIBILITY: Parse taxonomy analysis into structured metadata
//  - Extract topic hierarchy from analysis text
//  - Extract keywords, dependencies, and sentiment
//  - Provide defaults for missing data
//  - Zero side effects, pure transformation
//

import Foundation

struct MetadataParser {
    
    struct ParsedMetadata {
        let topicHierarchy: [String]
        let keywords: [String]
        let dependencies: [String]
        let sentiment: String
    }
    
    func parse(_ taxonomyAnalysis: String) -> ParsedMetadata {
        var topicHierarchy: [String] = []
        var keywords: [String] = []
        var dependencies: [String] = []
        var sentiment = "neutral"
        
        let lines = taxonomyAnalysis.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.hasPrefix("TOPIC:") {
                let topic = trimmedLine.replacingOccurrences(of: "TOPIC:", with: "").trimmingCharacters(in: .whitespaces)
                topicHierarchy = topic.split(separator: "/").map { String($0).trimmingCharacters(in: .whitespaces) }
            } else if trimmedLine.hasPrefix("KEYWORDS:") {
                let keywordString = trimmedLine.replacingOccurrences(of: "KEYWORDS:", with: "").trimmingCharacters(in: .whitespaces)
                keywords = keywordString.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            } else if trimmedLine.hasPrefix("DEPENDENCIES:") {
                let depString = trimmedLine.replacingOccurrences(of: "DEPENDENCIES:", with: "").trimmingCharacters(in: .whitespaces)
                dependencies = depString.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
            } else if trimmedLine.hasPrefix("SENTIMENT:") {
                sentiment = trimmedLine.replacingOccurrences(of: "SENTIMENT:", with: "").trimmingCharacters(in: .whitespaces).lowercased()
            }
            
            // Also handle variations without colons (as seen in actual LLM responses)
            if trimmedLine.lowercased().contains("topic_hierarchy:") || trimmedLine.lowercased().contains("topic hierarchy:") {
                if let range = trimmedLine.range(of: ":", options: .caseInsensitive) {
                    let hierarchyString = String(trimmedLine[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                    topicHierarchy = hierarchyString.split(separator: "/").map { String($0).trimmingCharacters(in: .whitespaces) }
                }
            }
            
            if trimmedLine.lowercased().contains("keywords:") && keywords.isEmpty {
                if let range = trimmedLine.range(of: ":", options: .caseInsensitive) {
                    let keywordString = String(trimmedLine[range.upperBound...]).trimmingCharacters(in: .whitespaces)
                    // Handle both comma-separated and bracket notation
                    let cleanedString = keywordString.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                    keywords = cleanedString.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespaces) }
                }
            }
        }
        
        // Provide defaults if not found
        if topicHierarchy.isEmpty {
            topicHierarchy = ["general", "conversation"]
        }
        if keywords.isEmpty {
            keywords = ["untagged"]
        }
        
        return ParsedMetadata(
            topicHierarchy: topicHierarchy,
            keywords: keywords,
            dependencies: dependencies,
            sentiment: sentiment
        )
    }
}