import Foundation
import SwiftUI

@MainActor
final class RuntimeModelManager: ObservableObject {
    static let shared = RuntimeModelManager()
    
    @Published var selectedModel: String
    
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
}