import Foundation
import SwiftUI

@MainActor
final class RuntimeModelManager: ObservableObject {
    static let shared = RuntimeModelManager()
    
    @Published var selectedModel: String
    @ObservedObject private var localModelDetector = LocalModelDetector.shared
    
    private init() {
        // Load default model from configuration
        if let defaultModel = ModelsConfiguration.shared.defaultModel {
            self.selectedModel = defaultModel
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
    
    /// Get all available models including local ones
    func getAvailableModels() -> [(provider: String, model: Model, isLocal: Bool)] {
        var availableModels: [(provider: String, model: Model, isLocal: Bool)] = []
        let modelsConfig = ModelsConfiguration.shared
        
        for (providerKey, provider) in modelsConfig.providers {
            for model in provider.models {
                let isLocal = providerKey == "ollama"
                
                // Include local models only if they are actually available
                if isLocal {
                    if localModelDetector.isModelAvailable(model.key) {
                        availableModels.append((providerKey, model, true))
                    }
                } else {
                    // Always include remote models
                    availableModels.append((providerKey, model, false))
                }
            }
        }
        
        return availableModels
    }
    
    /// Check if currently selected model is available
    func isCurrentModelAvailable() -> Bool {
        guard let (providerKey, _) = getCurrentModelConfiguration() else { return false }
        
        // Local models need to be actually available
        if providerKey == "ollama" {
            return localModelDetector.isModelAvailable(selectedModel)
        }
        
        // Remote models are assumed available
        return true
    }
}