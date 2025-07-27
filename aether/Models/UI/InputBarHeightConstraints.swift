//
//  InputBarHeightConstraints.swift
//  Aether
//
//  Model for input bar height constraints
//
//  ATOMIC RESPONSIBILITY: Data structure for height constraints
//  - Define minimum, maximum, and default heights
//  - Calculate constraints from design tokens
//  - Provide line-based height calculations
//  - Zero logic - pure data container
//

import Foundation

struct InputBarHeightConstraints {
    let minHeight: CGFloat
    let maxHeight: CGFloat
    let defaultHeight: CGFloat
    let lineHeight: CGFloat
    let maxVisibleLines: Int
    
    // MARK: - Factory Methods
    
    /// Create constraints from design tokens
    static func fromTokens(_ tokens: DesignTokens) -> InputBarHeightConstraints {
        // Get values from tokens
        let lineHeight = CGFloat(tokens.elements.inputBar.lineHeight ?? 17)
        let minHeight = CGFloat(tokens.elements.inputBar.minHeight)
        let maxVisibleLines = tokens.elements.inputBar.maxVisibleLines ?? 64
        
        // Calculate heights based on number of lines
        let topBottomPadding = tokens.elements.inputBar.topPadding * 2
        let defaultHeight = lineHeight + topBottomPadding
        
        // Calculate max height from max visible lines
        let maxHeight = (lineHeight * CGFloat(maxVisibleLines)) + topBottomPadding
        
        return InputBarHeightConstraints(
            minHeight: minHeight,
            maxHeight: maxHeight,
            defaultHeight: defaultHeight,
            lineHeight: lineHeight,
            maxVisibleLines: maxVisibleLines
        )
    }
    
    /// Calculate height for a given number of lines
    func height(forLines lineCount: Int) -> CGFloat {
        let clampedLines = min(lineCount, maxVisibleLines)
        let contentHeight = lineHeight * CGFloat(max(1, clampedLines))
        return contentHeight + (defaultHeight - lineHeight)
    }
    
    /// Check if scrolling should be enabled
    func shouldScroll(forLines lineCount: Int) -> Bool {
        return lineCount > maxVisibleLines
    }
}