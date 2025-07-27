//
//  VaultProtocols.swift
//  Aether
//
//  Protocol definitions for vault services
//
//  ATOMIC RESPONSIBILITY: Define contracts for vault operations
//  - VaultReading: Read operations for files and JSON
//  - VaultWriting: Write operations for files and JSON
//  - Enables dependency injection and testing
//  - Zero implementation, pure interface definition
//

import Foundation

// MARK: - VaultReading Protocol

/// Protocol for vault read operations
protocol VaultReading {
    /// Read a text file from the vault
    func readFile(at path: String) -> String?
    
    /// Read and decode JSON from the vault
    func readJSON<T: Decodable>(at path: String, as type: T.Type) -> T?
    
    /// Check if a file exists at the given path
    func fileExists(at path: String) -> Bool
    
    /// List files in a directory
    func listFiles(at path: String) -> [String]
}

// MARK: - VaultWriting Protocol

/// Protocol for vault write operations
protocol VaultWriting {
    /// Write a text file to the vault
    func writeFile(content: String, to path: String)
    
    /// Encode and write JSON to the vault
    func writeJSON<T: Encodable>(_ object: T, to path: String)
    
    /// Create a directory at the given path
    func createDirectory(at path: String)
    
    /// Delete a file at the given path
    func deleteFile(at path: String)
}