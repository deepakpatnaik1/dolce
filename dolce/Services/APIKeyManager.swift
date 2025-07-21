//
//  APIKeyManager.swift
//  Dolce
//
//  Atomic API key manager
//
//  ATOMIC RESPONSIBILITY: API key storage and retrieval only
//  - Get keys from environment variables
//  - Store/retrieve keys from keychain
//  - Basic key validation
//  - Zero configuration logic, zero persona logic
//

import Foundation
import Security

struct APIKeyManager {
    
    /// Get API key from environment variables or keychain
    static func getAPIKey(for identifier: String) -> String? {
        // Try environment variable first
        if let envKey = ProcessInfo.processInfo.environment[identifier], !envKey.isEmpty {
            return envKey
        }
        
        // Try keychain fallback
        return getAPIKeyFromKeychain(identifier)
    }
    
    /// Store API key in keychain
    static func storeAPIKey(_ key: String, for identifier: String) -> Bool {
        let data = key.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecAttrService as String: "Dolce",
            kSecValueData as String: data
        ]
        
        // Delete existing key first
        SecItemDelete(query as CFDictionary)
        
        // Add new key
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    // MARK: - Private Helpers
    
    private static func getAPIKeyFromKeychain(_ identifier: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: identifier,
            kSecAttrService as String: "Dolce",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let key = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return key
    }
}