//
//  FileReader.swift
//  Dolce
//
//  File I/O operations
//
//  ATOMIC RESPONSIBILITY: Read file data only
//  - Load file contents from URL
//  - Extract preview text based on type
//  - Return raw data and preview
//  - Zero validation or processing logic
//

import Foundation

struct FileReader {
    
    /// Result of reading a file
    struct FileContent {
        let data: Data
        let previewText: String?
    }
    
    /// File reading errors
    enum ReadError: LocalizedError {
        case unableToReadFile(String, Error)
        
        var errorDescription: String? {
            switch self {
            case .unableToReadFile(let name, let error):
                return "Failed to read file \(name): \(error.localizedDescription)"
            }
        }
    }
    
    /// Read file data and extract preview
    static func readFile(at url: URL, type: DroppedFile.FileType) async throws -> FileContent {
        do {
            let data = try Data(contentsOf: url)
            let preview = extractPreview(from: data, type: type)
            return FileContent(data: data, previewText: preview)
        } catch {
            throw ReadError.unableToReadFile(url.lastPathComponent, error)
        }
    }
    
    /// Extract preview text based on file type
    private static func extractPreview(from data: Data, type: DroppedFile.FileType) -> String? {
        switch type {
        case .text, .markdown, .code:
            // Try UTF-8 first, fall back to ASCII
            return String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii)
        case .image:
            return "Image file (\(formatBytes(data.count)))"
        case .pdf:
            return "PDF document (\(formatBytes(data.count)))"
        case .unknown:
            return "Binary file (\(formatBytes(data.count)))"
        }
    }
    
    /// Format byte count for display
    private static func formatBytes(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}