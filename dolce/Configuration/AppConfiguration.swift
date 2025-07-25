//
//  AppConfiguration.swift
//  dolce
//
//  Central app configuration for API settings, file paths, and limits
//

import Foundation

struct AppConfiguration: Codable {
    let api: APIConfiguration
    let fileSystem: FileSystemConfiguration
    let limits: LimitsConfiguration
    
    struct APIConfiguration: Codable {
        let defaultTimeout: Int
        let streamTimeout: Int
        let defaultTemperature: Double
        let httpStatus: HTTPStatusConfiguration
        let headers: HeadersConfiguration
        
        struct HTTPStatusConfiguration: Codable {
            let success: StatusRange
            let clientError: StatusRange
            let serverError: StatusRange
            
            struct StatusRange: Codable {
                let start: Int
                let end: Int
            }
        }
        
        struct HeadersConfiguration: Codable {
            let contentType: String
        }
    }
    
    struct FileSystemConfiguration: Codable {
        let paths: PathsConfiguration
        let files: FilesConfiguration
        let extensions: ExtensionsConfiguration
        
        struct PathsConfiguration: Codable {
            let journal: String
            let superjournal: String
            let personas: String
            let boss: String
            let tools: String
            let appState: String
        }
        
        struct FilesConfiguration: Codable {
            let currentPersona: String
            let scrollPosition: String
            let taxonomy: String
        }
        
        struct ExtensionsConfiguration: Codable {
            let markdown: String
            let json: String
        }
    }
    
    struct LimitsConfiguration: Codable {
        let defaultRecentTrims: Int
    }
    
    static let shared: AppConfiguration = {
        let configPath = VaultPathProvider.configPath(for: "app-configuration.json")
        let url = URL(fileURLWithPath: configPath)
        
        do {
            let data = try Data(contentsOf: url)
            let configuration = try JSONDecoder().decode(AppConfiguration.self, from: data)
            return configuration
        } catch {
            // Return default configuration if file cannot be loaded
            return AppConfiguration.createDefault()
        }
    }()
    
    private static func createDefault() -> AppConfiguration {
        return AppConfiguration(
            api: APIConfiguration(
                defaultTimeout: 120000,
                streamTimeout: 600000,
                defaultTemperature: 0.7,
                httpStatus: APIConfiguration.HTTPStatusConfiguration(
                    success: APIConfiguration.HTTPStatusConfiguration.StatusRange(start: 200, end: 299),
                    clientError: APIConfiguration.HTTPStatusConfiguration.StatusRange(start: 400, end: 499),
                    serverError: APIConfiguration.HTTPStatusConfiguration.StatusRange(start: 500, end: 599)
                ),
                headers: APIConfiguration.HeadersConfiguration(
                    contentType: "application/json"
                )
            ),
            fileSystem: FileSystemConfiguration(
                paths: FileSystemConfiguration.PathsConfiguration(
                    journal: "journal",
                    superjournal: "superjournal",
                    personas: "playbook/personas",
                    boss: "playbook/boss",
                    tools: "playbook/tools",
                    appState: ".app-state"
                ),
                files: FileSystemConfiguration.FilesConfiguration(
                    currentPersona: "currentPersona.md",
                    scrollPosition: "scrollPosition.json",
                    taxonomy: "taxonomy.json"
                ),
                extensions: FileSystemConfiguration.ExtensionsConfiguration(
                    markdown: ".md",
                    json: ".json"
                )
            ),
            limits: LimitsConfiguration(
                defaultRecentTrims: 10
            )
        )
    }
}