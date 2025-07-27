//
//  HeightCalculationRequest.swift
//  Aether
//
//  Model for debounced height calculation requests
//
//  ATOMIC RESPONSIBILITY: Data structure for height calculation requests
//  - Encapsulates request parameters
//  - Tracks request timing for debouncing
//  - Provides unique identifier for cancellation
//  - Zero logic - pure data container
//

import Foundation
import AppKit

struct HeightCalculationRequest: Identifiable, @unchecked Sendable {
    let id = UUID()
    let text: String
    let font: NSFont
    let availableWidth: CGFloat
    let requestTime: Date
    
    init(text: String, font: NSFont, availableWidth: CGFloat) {
        self.text = text
        self.font = font
        self.availableWidth = availableWidth
        self.requestTime = Date()
    }
}