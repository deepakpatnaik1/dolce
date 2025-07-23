//
//  InputBarState.swift
//  Dolce
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
    @Published var textHeight: CGFloat
    @Published var isFocused: Bool = false
    
    private let tokens = DesignTokens.shared
    
    init() {
        // Calculate initial single-line height
        let font = NSFont(name: DesignTokens.shared.typography.bodyFont, size: 12) ?? NSFont.systemFont(ofSize: 12)
        self.textHeight = TextMeasurementEngine.calculateLineHeight(for: font)
    }
    
    // MARK: - State Management
    
    /// Clear input state after sending
    func clearInput() {
        text = ""
        updateHeight(for: "")
    }
    
    /// Update text height based on content
    func updateHeight(for newText: String) {
        let font = NSFont(name: tokens.typography.bodyFont, size: 12) ?? NSFont.systemFont(ofSize: 12)
        let contentWidth: CGFloat = tokens.layout.sizing["contentWidth"] ?? 592
        let availableWidth = contentWidth - (tokens.elements.inputBar.textPadding * 2)
        
        let newHeight = TextMeasurementEngine.calculateHeight(
            for: newText,
            font: font,
            availableWidth: availableWidth
        )
        
        HeightAnimationEngine.animateHeightChange(
            from: textHeight,
            to: newHeight
        ) { [weak self] height in
            self?.textHeight = height
        }
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