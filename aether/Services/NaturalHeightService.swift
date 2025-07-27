//
//  NaturalHeightService.swift
//  Aether
//
//  Calculate default input bar height
//
//  ATOMIC RESPONSIBILITY: Calculate and preserve default height only
//  - Use design tokens for consistent sizing
//  - Calculate perfect empty-text height
//  - Zero animation logic, zero state management
//  - Pure calculation service
//

import Foundation
import AppKit

struct NaturalHeightService {
    
    /// Calculate the perfect default height for empty input
    static func calculateDefaultHeight(tokens: DesignTokens) -> CGFloat {
        // Get font from design tokens
        let font = NSFont(
            name: tokens.typography.bodyFont,
            size: CGFloat(tokens.elements.inputBar.fontSize)
        ) ?? NSFont.systemFont(ofSize: CGFloat(tokens.elements.inputBar.fontSize))
        
        // Get layout dimensions
        let contentWidth: CGFloat = tokens.layout.sizing["contentWidth"] ?? 592
        let availableWidth = contentWidth - (tokens.elements.inputBar.textPadding * 2)
        
        // Calculate height for empty string to get perfect default
        let attributes: [NSAttributedString.Key: Any] = [.font: font]
        let emptyString = NSAttributedString(string: "", attributes: attributes)
        
        let textStorage = NSTextStorage(attributedString: emptyString)
        let textContainer = NSTextContainer(size: CGSize(width: availableWidth, height: .greatestFiniteMagnitude))
        let layoutManager = NSLayoutManager()
        
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Force layout
        layoutManager.ensureLayout(for: textContainer)
        
        // Get the used rect
        let usedRect = layoutManager.usedRect(for: textContainer)
        
        // Use line height for empty text
        let lineHeight = layoutManager.defaultLineHeight(for: font)
        
        // Return the line height as the default (empty text shows one line)
        return max(lineHeight, usedRect.height)
    }
}