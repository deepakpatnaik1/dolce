//
//  DroppedFile.swift
//  Dolce
//
//  Pure data model for file attachments
//
//  ATOMIC RESPONSIBILITY: File attachment data structure only
//  - Immutable data with unique identifier for files
//  - Support for images, PDFs, and text files
//  - File metadata and content storage
//  - Zero business logic - pure data model
//

import Foundation
import AppKit

struct DroppedFile: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let type: FileType
    let size: Int64
    let data: Data
    let previewText: String?
    let timestamp: Date
    
    init(name: String, type: FileType, size: Int64, data: Data, previewText: String? = nil) {
        self.id = UUID()
        self.name = name
        self.type = type
        self.size = size
        self.data = data
        self.previewText = previewText
        self.timestamp = Date()
    }
    
    // File type classification
    enum FileType: String, CaseIterable, Codable {
        case image = "image"
        case pdf = "pdf"
        case text = "text"
        case markdown = "markdown"
        case code = "code"
        case unknown = "unknown"
        
        var displayName: String {
            switch self {
            case .image: return "Image"
            case .pdf: return "PDF"
            case .text: return "Text"
            case .markdown: return "Markdown"
            case .code: return "Code"
            case .unknown: return "File"
            }
        }
        
        var iconName: String {
            switch self {
            case .image: return "photo"
            case .pdf: return "doc.pdf"
            case .text: return "doc.text"
            case .markdown: return "doc.plaintext"
            case .code: return "curlybraces"
            case .unknown: return "doc"
            }
        }
        
        static func from(filename: String) -> FileType {
            let ext = URL(fileURLWithPath: filename).pathExtension.lowercased()
            
            switch ext {
            case "png", "jpg", "jpeg", "gif", "bmp", "tiff", "webp":
                return .image
            case "pdf":
                return .pdf
            case "txt":
                return .text
            case "md", "markdown":
                return .markdown
            case "swift", "js", "ts", "py", "java", "cpp", "c", "h", "css", "html", "json", "xml", "yml", "yaml":
                return .code
            default:
                return .unknown
            }
        }
    }
    
    // Computed properties
    var isImage: Bool {
        return type == .image
    }
    
    var formattedSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useMB, .useKB, .useBytes]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: size)
    }
    
    var displayContent: String {
        return previewText ?? "Binary file content"
    }
}