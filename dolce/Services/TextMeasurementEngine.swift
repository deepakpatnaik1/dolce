//
//  TextMeasurementEngine.swift
//  Dolce
//
//  Atomic text measurement
//
//  ATOMIC RESPONSIBILITY: Calculate exact text height only
//  - Use NSFont metrics for precise measurement
//  - Account for word wrapping and available width
//  - Calculate line count using real font metrics
//  - Apply window-aware max height constraints
//  - Zero animation logic, zero UI logic
//

import Foundation
import AppKit

struct TextMeasurementEngine {
    
    /// Calculate window-aware maximum text area height
    static func calculateMaximumTextHeight() -> CGFloat {
        let tokens = DesignTokens.shared
        
        guard let window = NSApplication.shared.windows.first else { 
            return CGFloat(tokens.layout.fallbacks["defaultWindowHeight"] ?? 400)
        }
        
        let windowHeight = window.frame.height
        
        // Calculate total chrome using design tokens
        let titleBarHeight = CGFloat(tokens.layout.chrome["titleBarHeight"] ?? 28)
        let containerPadding = CGFloat(tokens.layout.chrome["containerPadding"] ?? 16)
        let controlsRowHeight = CGFloat(tokens.layout.chrome["controlsRowHeight"] ?? 40)
        let textInternalPadding = CGFloat(tokens.layout.chrome["textInternalPadding"] ?? 24)
        
        let totalChrome = titleBarHeight + (containerPadding * 2) + textInternalPadding + controlsRowHeight
        let availableTextHeight = windowHeight - totalChrome
        
        let minTextHeight = CGFloat(tokens.layout.fallbacks["minTextHeight"] ?? 200)
        return max(minTextHeight, availableTextHeight)
    }
    
    /// Calculate exact height for given text with constraints applied
    /// Uses aether's proven line-count-first constraint approach
    static func calculateHeight(
        for text: String,
        font: NSFont,
        availableWidth: CGFloat
    ) -> CGFloat {
        // Step 1: Calculate actual line count needed
        let actualLineCount = calculateLineCount(for: text, font: font, availableWidth: availableWidth)
        
        // Step 2: Calculate maximum line count that fits in window
        let maxHeight = calculateMaximumTextHeight()
        let lineHeight = calculateLineHeight(for: font)
        let maxLineCount = Int(floor(maxHeight / lineHeight))
        
        // Step 3: Constrain line count first (aether's approach)
        let constrainedLineCount = min(actualLineCount, maxLineCount)
        
        // Step 4: Calculate final height from constrained line count
        return CGFloat(constrainedLineCount) * lineHeight
    }
    
    /// Calculate unbounded text height (internal use only)
    private static func calculateUnboundedHeight(
        for text: String,
        font: NSFont,
        availableWidth: CGFloat
    ) -> CGFloat {
        let measureText = text.isEmpty ? "Ag" : text
        
        let attributedString = NSAttributedString(
            string: measureText,
            attributes: [
                .font: font,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.lineBreakMode = .byWordWrapping
                    return style
                }()
            ]
        )
        
        let boundingRect = attributedString.boundingRect(
            with: CGSize(width: availableWidth, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        
        return ceil(boundingRect.height)
    }
    
    /// Calculate exact line count using font metrics
    static func calculateLineCount(
        for text: String,
        font: NSFont,
        availableWidth: CGFloat
    ) -> Int {
        let totalHeight = calculateUnboundedHeight(for: text, font: font, availableWidth: availableWidth)
        let lineHeight = calculateLineHeight(for: font)
        
        return max(1, Int(ceil(totalHeight / lineHeight)))
    }
    
    /// Calculate single line height using font metrics
    static func calculateLineHeight(for font: NSFont) -> CGFloat {
        return font.ascender + abs(font.descender) + font.leading
    }
}