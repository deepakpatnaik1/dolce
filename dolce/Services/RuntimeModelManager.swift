import Foundation
import SwiftUI

@MainActor
final class RuntimeModelManager: ObservableObject {
    static let shared = RuntimeModelManager()
    
    @Published var selectedModel: String
    
    private init() {
        // Load default model from persona mapping (single source of truth)
        if let claudeDefault = PersonaMappingLoader.getDefaultModel(for: .claude) {
            // Default to Claude model with provider prefix
            self.selectedModel = "anthropic:\(claudeDefault)"
        } else if let nonClaudeDefault = PersonaMappingLoader.getDefaultModel(for: .nonClaude) {
            // Use the default non-Claude model from persona mapping
            // Need to add provider prefix for OpenAI models
            self.selectedModel = "openai:\(nonClaudeDefault)"
        } else {
            // Fallback if no default specified
            self.selectedModel = ""
        }
    }
    
    func selectModel(_ modelKey: String) {
        selectedModel = modelKey
    }
    
    func getCurrentModelConfiguration() -> (provider: String, model: Model)? {
        guard !selectedModel.isEmpty else { return nil }
        
        let modelsConfig = ModelsConfiguration.shared
        
        // Find the selected model in any provider
        for (providerKey, provider) in modelsConfig.providers {
            if let model = provider.models.first(where: { $0.key == selectedModel }) {
                return (providerKey, model)
            }
        }
        
        return nil
    }
    
    /// Get all available models
    func getAvailableModels() -> [(provider: String, model: Model, isLocal: Bool)] {
        var availableModels: [(provider: String, model: Model, isLocal: Bool)] = []
        let modelsConfig = ModelsConfiguration.shared
        
        for (providerKey, provider) in modelsConfig.providers {
            for model in provider.models {
                // Include all models - check availability later
                availableModels.append((providerKey, model, false))
            }
        }
        
        return availableModels
    }
    
    /// Check if currently selected model is available
    func isCurrentModelAvailable() -> Bool {
        guard let _ = getCurrentModelConfiguration() else { return false }
        
        // Remote models are assumed available
        return true
    }
}