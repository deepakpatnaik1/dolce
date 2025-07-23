//
//  FilePickerService.swift
//  Dolce
//
//  System file picker operations
//
//  ATOMIC RESPONSIBILITY: File selection UI only
//  - Show native file picker dialog
//  - Return selected file URLs
//  - Configure picker options
//  - Zero file reading or validation
//

import Foundation
import AppKit
import UniformTypeIdentifiers

struct FilePickerService {
    
    // Supported file types for picker
    static let supportedTypes: [UTType] = [
        .image,
        .pdf,
        .plainText,
        .sourceCode,
        .json
    ]
    
    /// Show system file picker and return selected URLs
    /// Returns empty array if cancelled
    @MainActor
    static func pickFiles() async -> [URL] {
        await withCheckedContinuation { continuation in
            let panel = NSOpenPanel()
            
            // Configure picker
            panel.allowsMultipleSelection = true
            panel.canChooseDirectories = false
            panel.canChooseFiles = true
            panel.allowedContentTypes = supportedTypes
            
            // Show picker
            if panel.runModal() == .OK {
                continuation.resume(returning: panel.urls)
            } else {
                continuation.resume(returning: [])
            }
        }
    }
}