//
//  ModelsConfiguration.swift
//  Aether
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
            // Return default configuration if file cannot be loaded
            return ModelsConfiguration.createDefault()
        }
    }()
    
    private static func createDefault() -> ModelsConfiguration {
        // Return minimal default configuration to allow app to run
        return ModelsConfiguration(
            providers: [
                "anthropic": ProviderConfiguration(
                    name: "Anthropic",
                    apiKeyIdentifier: "ANTHROPIC_API_KEY",
                    baseURL: "https://api.anthropic.com",
                    endpoint: "/v1/messages",
                    authHeader: "x-api-key",
                    authPrefix: nil,
                    models: [
                        ModelConfiguration(
                            key: "claude-3-5-sonnet-20241022",
                            displayName: "Claude 3.5 Sonnet",
                            maxTokens: 8192,
                            isLocal: false
                        )
                    ],
                    additionalHeaders: [
                        "anthropic-version": "2023-06-01"
                    ]
                )
            ]
        )
    }
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