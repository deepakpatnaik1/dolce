//
//  LocalModelDetector.swift
//  Dolce
//
//  Atomic local model detection
//
//  ATOMIC RESPONSIBILITY: Detect available local models only
//  - Check Ollama service availability
//  - Query available local models via API
//  - Return model availability status
//  - Zero model management, zero configuration, zero UI logic
//

import Foundation

@MainActor
final class LocalModelDetector: ObservableObject {
    static let shared = LocalModelDetector()
    
    @Published private(set) var isOllamaAvailable: Bool = false
    @Published private(set) var availableModels: Set<String> = []
    private var hasChecked: Bool = false
    
    private let ollamaBaseURL = "http://localhost:11434"
    
    private init() {
        // Don't check on init to avoid blocking startup
        // Will be checked when models are actually needed
    }
    
    // MARK: - Availability Detection
    
    /// Check if Ollama service is running
    func checkOllamaAvailability() {
        // Temporarily disable network requests to prevent crashes
        // TODO: Re-enable when network issues are resolved
        updateAvailability(false, models: [])
        
        /*
        guard let url = URL(string: "\(ollamaBaseURL)/api/tags") else {
            updateAvailability(false, models: [])
            return
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = 1.0 // Very quick timeout to avoid blocking
        
        Task {
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse,
                      200...299 ~= httpResponse.statusCode else {
                    updateAvailability(false, models: [])
                    return
                }
                
                let models = parseAvailableModels(from: data)
                updateAvailability(true, models: models)
                
            } catch {
                // Silently fail - local service not available
                updateAvailability(false, models: [])
            }
        }
        */
    }
    
    /// Check if specific model is available locally
    func isModelAvailable(_ modelKey: String) -> Bool {
        // Don't trigger network requests during property access
        return availableModels.contains(modelKey)
    }
    
    /// Get all available local model keys
    func getAvailableLocalModels() -> [String] {
        return Array(availableModels).sorted()
    }
    
    /// Refresh availability (call when needed)
    func refresh() {
        hasChecked = true
        checkOllamaAvailability()
    }
    
    /// Safe check that doesn't trigger network on first access
    func refreshIfNeeded() {
        guard !hasChecked else { return }
        refresh()
    }
    
    // MARK: - Private Helpers
    
    private func parseAvailableModels(from data: Data) -> [String] {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let models = json["models"] as? [[String: Any]] else {
            return []
        }
        
        return models.compactMap { model in
            model["name"] as? String
        }
    }
    
    @MainActor
    private func updateAvailability(_ available: Bool, models: [String]) {
        self.isOllamaAvailable = available
        self.availableModels = Set(models)
    }
}