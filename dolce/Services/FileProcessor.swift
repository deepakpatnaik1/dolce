//
//  FileProcessor.swift
//  Dolce
//
//  Pure transformation service for file content processing
//
//  ATOMIC RESPONSIBILITY: File content extraction and formatting only
//  - Extract readable content from different file types
//  - Format content for ChatMessage integration
//  - Compress and summarize content when needed
//  - Zero UI logic - pure content transformation
//

import Foundation
import AppKit
import PDFKit

struct FileProcessor {
    
    // Process files for chat integration
    static func processFilesForChat(_ files: [DroppedFile]) -> String {
        guard !files.isEmpty else { return "" }
        
        var processedContent: [String] = []
        
        for file in files {
            let content = processFile(file)
            processedContent.append(content)
        }
        
        return formatForChat(processedContent, fileCount: files.count)
    }
    
    // Process individual file
    static func processFile(_ file: DroppedFile) -> String {
        switch file.type {
        case .image:
            return processImage(file)
        case .pdf:
            return processPDF(file)
        case .text, .markdown, .code:
            return processText(file)
        case .unknown:
            return processUnknown(file)
        }
    }
    
    // Generate chat-ready summary
    static func generateChatSummary(_ files: [DroppedFile]) -> String {
        let fileTypes = Dictionary(grouping: files) { $0.type }
        var summary: [String] = []
        
        for (type, files) in fileTypes {
            let count = files.count
            let typeDesc = count == 1 ? type.displayName.lowercased() : "\(type.displayName.lowercased())s"
            summary.append("\(count) \(typeDesc)")
        }
        
        let fileDescription = summary.joined(separator: ", ")
        return "I've attached \(fileDescription) to this message."
    }
    
    // MARK: - Private Processing Methods
    
    private static func processImage(_ file: DroppedFile) -> String {
        guard let image = NSImage(data: file.data) else {
            return "**\(file.name)** (image file - unable to process)\n"
        }
        
        let size = image.size
        return """
        **\(file.name)** (Image - \(Int(size.width))×\(Int(size.height))px, \(file.formattedSize))
        
        [Image content available for analysis]
        
        """
    }
    
    private static func processPDF(_ file: DroppedFile) -> String {
        guard let pdfDocument = PDFDocument(data: file.data) else {
            return "**\(file.name)** (PDF - unable to process)\n"
        }
        
        let pageCount = pdfDocument.pageCount
        var extractedText = ""
        
        // Extract text from first few pages (limit to avoid overwhelming context)
        let maxPages = min(pageCount, 3)
        for pageIndex in 0..<maxPages {
            if let page = pdfDocument.page(at: pageIndex),
               let pageText = page.string {
                extractedText += pageText + "\n\n"
            }
        }
        
        // Trim and limit content
        extractedText = extractedText.trimmingCharacters(in: .whitespacesAndNewlines)
        if extractedText.count > 2000 {
            extractedText = String(extractedText.prefix(2000)) + "...\n\n[Content truncated - full PDF available]"
        }
        
        let suffix = pageCount > maxPages ? " (showing first \(maxPages) of \(pageCount) pages)" : ""
        
        return """
        **\(file.name)** (PDF - \(pageCount) pages, \(file.formattedSize))\(suffix)
        
        \(extractedText.isEmpty ? "[PDF content available for analysis]" : extractedText)
        
        """
    }
    
    private static func processText(_ file: DroppedFile) -> String {
        guard let text = file.previewText, !text.isEmpty else {
            return "**\(file.name)** (\(file.type.displayName) - empty file)\n"
        }
        
        var content = text
        
        // Limit very long text files
        if content.count > 3000 {
            content = String(content.prefix(3000)) + "...\n\n[Content truncated - full file available]"
        }
        
        return """
        **\(file.name)** (\(file.type.displayName) - \(file.formattedSize))
        
        ```
        \(content)
        ```
        
        """
    }
    
    private static func processUnknown(_ file: DroppedFile) -> String {
        return """
        **\(file.name)** (Unknown file type - \(file.formattedSize))
        
        [Binary file content available]
        
        """
    }
    
    private static func formatForChat(_ processedContent: [String], fileCount: Int) -> String {
        let header = fileCount == 1 ? 
            "📎 File attachment:\n\n" : 
            "📎 \(fileCount) file attachments:\n\n"
        
        return header + processedContent.joined(separator: "---\n\n")
    }
}