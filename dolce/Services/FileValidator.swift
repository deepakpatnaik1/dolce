//
//  FileValidator.swift
//  Dolce
//
//  File validation rules
//
//  ATOMIC RESPONSIBILITY: Validate file constraints only
//  - Check file size limits
//  - Verify supported file types
//  - Return validation results
//  - Zero file reading or processing
//

import Foundation

struct FileValidator {
    
    // Maximum file size (10MB)
    static let maxFileSize: Int64 = 10 * 1024 * 1024
    
    // Validation result
    struct ValidationResult {
        let url: URL
        let fileName: String
        let fileType: DroppedFile.FileType
        let fileSize: Int64
    }
    
    // Validation errors
    enum ValidationError: LocalizedError {
        case fileTooLarge(String, Int64)
        case unableToGetFileSize(String)
        
        var errorDescription: String? {
            switch self {
            case .fileTooLarge(let name, let size):
                let sizeMB = Double(size) / (1024 * 1024)
                return "File too large: \(name) (\(String(format: "%.1f", sizeMB))MB, max 10MB)"
            case .unableToGetFileSize(let name):
                return "Unable to determine size of file: \(name)"
            }
        }
    }
    
    /// Validate file at URL against constraints
    static func validate(url: URL) -> Result<ValidationResult, ValidationError> {
        let fileName = url.lastPathComponent
        
        // Get file size
        guard let fileSize = getFileSize(at: url) else {
            return .failure(.unableToGetFileSize(fileName))
        }
        
        // Check size limit
        if fileSize > maxFileSize {
            return .failure(.fileTooLarge(fileName, fileSize))
        }
        
        // Determine file type
        let fileType = DroppedFile.FileType.from(filename: fileName)
        
        // Return validation result
        return .success(ValidationResult(
            url: url,
            fileName: fileName,
            fileType: fileType,
            fileSize: fileSize
        ))
    }
    
    /// Get file size at URL
    private static func getFileSize(at url: URL) -> Int64? {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
            return attributes[.size] as? Int64
        } catch {
            return nil
        }
    }
}