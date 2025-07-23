//
//  FileDropHandler.swift
//  Dolce
//
//  Pure logic handler for file drop operations
//
//  ATOMIC RESPONSIBILITY: File drop mechanics only
//  - Handle SwiftUI .onDrop provider interactions
//  - Validate dropped files against supported types
//  - Extract file data and metadata
//  - Zero UI logic - pure drop handling
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import AppKit

@MainActor
class FileDropHandler: ObservableObject {
    @Published var isHovering = false
    @Published var droppedFiles: [DroppedFile] = []
    @Published var dropError: String?
    
    // Supported file types
    private let supportedTypes: [UTType] = [
        .image,
        .pdf,
        .plainText,
        .utf8PlainText,
        .sourceCode,
        .json,
        .xml
    ]
    
    // Maximum file size from configuration
    private var maxFileSize: Int64 { AppConfigurationLoader.maxFileSize }
    
    func handleDrop(providers: [NSItemProvider]) -> Bool {
        Task {
            await processDroppedItems(providers)
        }
        return true
    }
    
    
    func clearFiles() {
        Task { @MainActor in
            droppedFiles.removeAll()
            dropError = nil
        }
    }
    
    func removeFile(id: UUID) {
        Task { @MainActor in
            droppedFiles.removeAll { $0.id == id }
        }
    }
    
    func addFile(_ file: DroppedFile) {
        Task { @MainActor in
            droppedFiles.append(file)
        }
    }
    
    func captureClipboardText() {
        Task { @MainActor in
            let pasteboard = NSPasteboard.general
            
            // Check if there's text in clipboard
            guard let clipboardText = pasteboard.string(forType: .string),
                  !clipboardText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                return
            }
            
            // Capture any text content
            
            // Convert clipboard text to DroppedFile
            let textData = clipboardText.data(using: .utf8) ?? Data()
            let fileName = generateClipboardFileName(for: clipboardText)
            let fileType = determineTextFileType(from: clipboardText)
            
            let droppedFile = DroppedFile(
                name: fileName,
                type: fileType,
                size: Int64(textData.count),
                data: textData,
                previewText: clipboardText
            )
            
            droppedFiles.append(droppedFile)
        }
    }
    
    private func processDroppedItems(_ providers: [NSItemProvider]) async {
        var newFiles: [DroppedFile] = []
        
        for provider in providers {
            if let droppedFile = await processProvider(provider) {
                newFiles.append(droppedFile)
            }
        }
        
        if !newFiles.isEmpty {
            droppedFiles.append(contentsOf: newFiles)
            isHovering = false
        }
    }
    
    private func processProvider(_ provider: NSItemProvider) async -> DroppedFile? {
        // Try to get file URL first
        if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
            return await loadFromFileURL(provider)
        }
        
        // Try supported types
        for type in supportedTypes {
            if provider.hasItemConformingToTypeIdentifier(type.identifier) {
                return await loadFromType(provider, type: type)
            }
        }
        
        return nil
    }
    
    private func loadFromFileURL(_ provider: NSItemProvider) async -> DroppedFile? {
        // Capture max file size before entering the closure
        let maxFileSizeLimit = maxFileSize
        
        return await withCheckedContinuation { continuation in
            _ = provider.loadObject(ofClass: URL.self) { url, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.dropError = "Failed to load file: \(error.localizedDescription)"
                    }
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let url = url, url.isFileURL else {
                    continuation.resume(returning: nil)
                    return
                }
                
                do {
                    let data = try Data(contentsOf: url)
                    let name = url.lastPathComponent
                    let size = Int64(data.count)
                    
                    // Check file size
                    if size > maxFileSizeLimit {
                        let maxMB = Double(maxFileSizeLimit) / (1024 * 1024)
                        DispatchQueue.main.async {
                            self.dropError = "File too large: \(name) (max \(String(format: "%.0f", maxMB))MB)"
                        }
                        continuation.resume(returning: nil)
                        return
                    }
                    
                    let fileType = DroppedFile.FileType.from(filename: name)
                    let previewText = FileDropHandler.extractPreviewText(from: data, type: fileType)
                    
                    let droppedFile = DroppedFile(
                        name: name,
                        type: fileType,
                        size: size,
                        data: data,
                        previewText: previewText
                    )
                    
                    continuation.resume(returning: droppedFile)
                } catch {
                    DispatchQueue.main.async {
                        self.dropError = "Failed to read file: \(error.localizedDescription)"
                    }
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    private func loadFromType(_ provider: NSItemProvider, type: UTType) async -> DroppedFile? {
        // Capture max file size before entering the closure
        let maxFileSizeLimit = maxFileSize
        
        return await withCheckedContinuation { continuation in
            _ = provider.loadDataRepresentation(forTypeIdentifier: type.identifier) { data, error in
                if let error = error {
                    DispatchQueue.main.async {
                        self.dropError = "Failed to load data: \(error.localizedDescription)"
                    }
                    continuation.resume(returning: nil)
                    return
                }
                
                guard let data = data else {
                    continuation.resume(returning: nil)
                    return
                }
                
                let size = Int64(data.count)
                
                // Check file size
                if size > maxFileSizeLimit {
                    let maxMB = Double(maxFileSizeLimit) / (1024 * 1024)
                    DispatchQueue.main.async {
                        self.dropError = "File too large (max \(String(format: "%.0f", maxMB))MB)"
                    }
                    continuation.resume(returning: nil)
                    return
                }
                
                let name = FileDropHandler.generateFileName(for: type)
                let fileType = FileDropHandler.mapUTTypeToFileType(type)
                let previewText = FileDropHandler.extractPreviewText(from: data, type: fileType)
                
                let droppedFile = DroppedFile(
                    name: name,
                    type: fileType,
                    size: size,
                    data: data,
                    previewText: previewText
                )
                
                continuation.resume(returning: droppedFile)
            }
        }
    }
    
    nonisolated private static func extractPreviewText(from data: Data, type: DroppedFile.FileType) -> String? {
        switch type {
        case .text, .markdown, .code:
            return String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii)
        case .image:
            return "Image file (\(data.count) bytes)"
        case .pdf:
            return "PDF document (\(data.count) bytes)"
        case .unknown:
            return "Binary file (\(data.count) bytes)"
        }
    }
    
    nonisolated private static func generateFileName(for type: UTType) -> String {
        let timestamp = Date().formatted(.dateTime.hour().minute().second())
        
        switch type {
        case .image:
            return "image_\(timestamp).png"
        case .pdf:
            return "document_\(timestamp).pdf"
        case .plainText, .utf8PlainText:
            return "text_\(timestamp).txt"
        default:
            return "file_\(timestamp)"
        }
    }
    
    nonisolated private static func mapUTTypeToFileType(_ type: UTType) -> DroppedFile.FileType {
        switch type {
        case .image:
            return .image
        case .pdf:
            return .pdf
        case .plainText, .utf8PlainText:
            return .text
        case .sourceCode:
            return .code
        case .json, .xml:
            return .code
        default:
            return .unknown
        }
    }
    
    // MARK: - Clipboard Helper Functions
    
    nonisolated private func generateClipboardFileName(for text: String) -> String {
        let timestamp = Date().formatted(.dateTime.hour().minute().second())
        
        // Try to detect content type from text patterns
        if text.contains("```") || text.contains("function ") || text.contains("class ") || text.contains("import ") {
            return "code_\(timestamp).txt"
        } else if text.contains("# ") || text.contains("## ") || text.contains("**") {
            return "notes_\(timestamp).md"
        } else if text.contains("http") || text.contains("www.") {
            return "links_\(timestamp).txt"
        } else {
            return "clipboard_\(timestamp).txt"
        }
    }
    
    nonisolated private func determineTextFileType(from text: String) -> DroppedFile.FileType {
        // Simple heuristics to determine file type from content
        if text.contains("```") || 
           text.contains("function ") || 
           text.contains("class ") || 
           text.contains("import ") ||
           text.contains("def ") ||
           text.contains("const ") ||
           text.contains("var ") {
            return .code
        } else if text.contains("# ") || 
                  text.contains("## ") || 
                  text.contains("**") || 
                  text.contains("*") ||
                  text.contains("[") && text.contains("](") {
            return .markdown
        } else {
            return .text
        }
    }
}