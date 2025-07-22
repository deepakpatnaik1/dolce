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
//  - Zero animation logic, zero UI logic
//

import Foundation
import AppKit

struct TextMeasurementEngine {
    
    /// Calculate exact height for given text and constraints
    static func calculateHeight(
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
        let totalHeight = calculateHeight(for: text, font: font, availableWidth: availableWidth)
        let lineHeight = font.ascender + abs(font.descender) + font.leading
        
        return max(1, Int(ceil(totalHeight / lineHeight)))
    }
    
    /// Calculate single line height using font metrics
    static func calculateLineHeight(for font: NSFont) -> CGFloat {
        return font.ascender + abs(font.descender) + font.leading
    }
}