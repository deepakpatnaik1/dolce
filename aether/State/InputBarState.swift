//
//  InputBarState.swift
//  Aether
//
//  Pure UI state management for input bar
//
//  ATOMIC RESPONSIBILITY: Input bar UI state only
//  - Track text input state
//  - Manage text field height
//  - Handle focus state
//  - Zero business logic - pure state container
//

import Foundation
import SwiftUI


@MainActor
class InputBarState: ObservableObject {
    @Published var text: String = ""
    @Published var isFocused: Bool = false
    
    let defaultHeight: CGFloat
    let heightManager: InputBarHeightManager
    private let tokens = DesignTokens.shared
    
    init() {
        // Calculate perfect default height using natural height service
        self.defaultHeight = NaturalHeightService.calculateDefaultHeight(tokens: tokens)
        
        // Initialize height manager with constraints
        let constraints = InputBarHeightConstraints.fromTokens(tokens)
        self.heightManager = InputBarHeightManager(constraints: constraints)
    }
    
    
    // MARK: - State Management
    
    /// Clear input state after sending
    func clearInput() {
        text = ""
        heightManager.reset()
    }
    
    
    /// Check if input has content
    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Get trimmed text content
    var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
}