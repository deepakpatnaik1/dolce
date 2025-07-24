//
//  MockVaultServices.swift
//  Dolce
//
//  Mock implementations of vault protocols for testing
//
//  ATOMIC RESPONSIBILITY: Provide test doubles for vault operations
//  - MockVaultReader: In-memory implementation of VaultReading
//  - MockVaultWriter: Captures writes for verification
//  - Enables unit testing without file system dependencies
//  - Zero actual file I/O
//

import Foundation

// MARK: - MockVaultReader

class MockVaultReader: VaultReading {
    private var files: [String: String] = [:]
    private var jsonData: [String: Data] = [:]
    
    /// Add a file to the mock reader
    func addFile(at path: String, content: String) {
        files[path] = content
    }
    
    /// Add JSON data to the mock reader
    func addJSON<T: Encodable>(at path: String, object: T) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(object)
        jsonData[path] = data
        files[path] = String(data: data, encoding: .utf8) ?? ""
    }
    
    // MARK: - VaultReading Implementation
    
    func readFile(at path: String) -> String? {
        return files[path]
    }
    
    func readJSON<T: Decodable>(at path: String, as type: T.Type) -> T? {
        guard let data = jsonData[path] else {
            // Try to decode from string if JSON data not found
            if let string = files[path],
               let stringData = string.data(using: .utf8) {
                return try? JSONDecoder().decode(type, from: stringData)
            }
            return nil
        }
        return try? JSONDecoder().decode(type, from: data)
    }
    
    func fileExists(at path: String) -> Bool {
        return files[path] != nil
    }
    
    func listFiles(at path: String) -> [String] {
        // Return files that start with the given path
        return files.keys
            .filter { $0.hasPrefix(path + "/") }
            .map { URL(fileURLWithPath: $0).lastPathComponent }
    }
}

// MARK: - MockVaultWriter

class MockVaultWriter: VaultWriting {
    private(set) var writtenFiles: [String: String] = [:]
    private(set) var writtenJSON: [String: Any] = [:]
    private(set) var createdDirectories: Set<String> = []
    private(set) var deletedFiles: Set<String> = []
    
    /// Clear all captured data
    func reset() {
        writtenFiles.removeAll()
        writtenJSON.removeAll()
        createdDirectories.removeAll()
        deletedFiles.removeAll()
    }
    
    /// Check if a file was written
    func wasFileWritten(at path: String) -> Bool {
        return writtenFiles[path] != nil
    }
    
    /// Get the content written to a file
    func getWrittenContent(at path: String) -> String? {
        return writtenFiles[path]
    }
    
    // MARK: - VaultWriting Implementation
    
    func writeFile(content: String, to path: String) {
        writtenFiles[path] = content
        
        // Simulate directory creation
        let directory = (path as NSString).deletingLastPathComponent
        if !directory.isEmpty && directory != "." {
            createdDirectories.insert(directory)
        }
    }
    
    func writeJSON<T: Encodable>(_ object: T, to path: String) {
        writtenJSON[path] = object
        
        // Also store as string for file checking
        if let data = try? JSONEncoder().encode(object),
           let string = String(data: data, encoding: .utf8) {
            writtenFiles[path] = string
        }
    }
    
    func createDirectory(at path: String) {
        createdDirectories.insert(path)
    }
    
    func deleteFile(at path: String) {
        deletedFiles.insert(path)
        writtenFiles.removeValue(forKey: path)
        writtenJSON.removeValue(forKey: path)
    }
}