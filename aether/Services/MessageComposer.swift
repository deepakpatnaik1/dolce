//
//  MessageComposer.swift
//  Aether
//
//  Message content assembly
//
//  ATOMIC RESPONSIBILITY: Compose final message only
//  - Combine text and file content
//  - Format message structure
//  - Generate file summaries
//  - Zero file processing or validation
//

import Foundation

struct MessageComposer {
    
    /// Compose final message from text and files
    static func compose(text: String, files: [DroppedFile]) -> String {
        let trimmedText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasText = !trimmedText.isEmpty
        let hasFiles = !files.isEmpty
        
        // Text only
        if hasText && !hasFiles {
            return trimmedText
        }
        
        // Files only
        if !hasText && hasFiles {
            let summary = generateFileSummary(files)
            let content = FileProcessor.processFilesForChat(files)
            return "\(summary)\n\n\(content)"
        }
        
        // Text and files
        if hasText && hasFiles {
            let content = FileProcessor.processFilesForChat(files)
            return "\(trimmedText)\n\n\(content)"
        }
        
        // Nothing (shouldn't happen, but be defensive)
        return ""
    }
    
    /// Generate summary of attached files
    private static func generateFileSummary(_ files: [DroppedFile]) -> String {
        if files.isEmpty {
            return ""
        }
        
        if files.count == 1 {
            let file = files[0]
            return "I've attached \(file.name)"
        }
        
        let fileList = files.map { $0.name }.joined(separator: ", ")
        return "I've attached \(files.count) files: \(fileList)"
    }
}