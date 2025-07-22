//
//  ModelsConfiguration.swift
//  Dolce
//
//  Atomic models configuration loader
//
//  ATOMIC RESPONSIBILITY: Load models configuration from JSON only
//  - Read Models.json configuration file
//  - Parse provider and model definitions
//  - Provide typed access to configuration data
//  - Zero business logic, zero API logic
//

import Foundation

// MARK: - Configuration Data Models

struct ModelsConfiguration: Codable {
    let defaultModel: String?
    let providers: [String: ProviderConfiguration]
    
    static let shared: ModelsConfiguration = {
        guard let url = Bundle.main.url(forResource: "Models", withExtension: "json") else {
            fatalError("❌ Models.json not found in app bundle")
        }
        
        do {
            let data = try Data(contentsOf: url)
            let configuration = try JSONDecoder().decode(ModelsConfiguration.self, from: data)
            print("✅ Models configuration loaded successfully")
            return configuration
        } catch {
            fatalError("❌ Failed to load Models.json: \(error)")
        }
    }()
}

struct ProviderConfiguration: Codable {
    let name: String
    let apiKeyIdentifier: String?
    let baseURL: String
    let endpoint: String
    let authHeader: String?
    let authPrefix: String?
    let models: [ModelConfiguration]
    let additionalHeaders: [String: String]?
}

struct ModelConfiguration: Codable {
    let key: String
    let displayName: String
    let maxTokens: Int
    let isLocal: Bool?
}

// Type alias for clarity
typealias Model = ModelConfiguration