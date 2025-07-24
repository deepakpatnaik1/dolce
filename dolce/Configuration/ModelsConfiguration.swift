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
    let providers: [String: ProviderConfiguration]
    
    static let shared: ModelsConfiguration = {
        let configPath = VaultPathProvider.configPath(for: "models.json")
        let url = URL(fileURLWithPath: configPath)
        
        do {
            let data = try Data(contentsOf: url)
            let configuration = try JSONDecoder().decode(ModelsConfiguration.self, from: data)
            return configuration
        } catch {
            fatalError("Failed to load models.json from vault at \(configPath): \(error)")
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