//
//  InputBarHeightManager.swift
//  Aether
//
//  Service for managing input bar height calculations
//
//  ATOMIC RESPONSIBILITY: Calculate and manage input bar heights
//  - Track current height based on text content
//  - Determine when scrolling should activate
//  - Animate height changes smoothly
//  - Respect maximum height constraints
//

import Foundation
import SwiftUI

@MainActor
class InputBarHeightManager: ObservableObject {
    @Published var currentHeight: CGFloat
    @Published var shouldEnableScroll: Bool = false
    
    let constraints: InputBarHeightConstraints
    private let tokens = DesignTokens.shared
    private var lastLineCount: Int = 1
    
    init(constraints: InputBarHeightConstraints) {
        self.constraints = constraints
        self.currentHeight = constraints.defaultHeight
    }
    
    // MARK: - Public Interface
    
    /// Calculate height for the given text
    func calculateHeight(for text: String) -> CGFloat {
        let lineCount = countLines(in: text)
        let newHeight = constraints.height(forLines: lineCount)
        
        // Update scroll state
        shouldEnableScroll = constraints.shouldScroll(forLines: lineCount)
        
        // Store line count for animations
        lastLineCount = lineCount
        
        return newHeight
    }
    
    /// Update current height with animation if needed
    func updateHeight(for text: String) {
        let newHeight = calculateHeight(for: text)
        
        // Only animate if height is actually changing
        if abs(currentHeight - newHeight) > 0.1 {
            withAnimation(.spring(
                response: tokens.animations.textExpansion.response,
                dampingFraction: tokens.animations.textExpansion.dampingFraction
            )) {
                currentHeight = newHeight
            }
        }
    }
    
    /// Check if we're at maximum height
    var isAtMaxHeight: Bool {
        return currentHeight >= constraints.maxHeight - 0.1
    }
    
    /// Reset to default height
    func reset() {
        withAnimation(.spring(
            response: tokens.animations.textExpansion.response,
            dampingFraction: tokens.animations.textExpansion.dampingFraction
        )) {
            currentHeight = constraints.defaultHeight
            shouldEnableScroll = false
            lastLineCount = 1
        }
    }
    
    // MARK: - Private Helpers
    
    /// Count lines in the text
    private func countLines(in text: String) -> Int {
        guard !text.isEmpty else { return 1 }
        
        // Count newline characters
        let newlineCount = text.filter { $0.isNewline }.count
        
        // Add 1 for the last line without newline
        return newlineCount + 1
    }
    
    /// Get effective height considering constraints
    func effectiveHeight(for proposedHeight: CGFloat) -> CGFloat {
        return min(max(proposedHeight, constraints.minHeight), constraints.maxHeight)
    }
}