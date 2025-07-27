//
//  GlassmorphicEffectStyle.swift
//  Aether
//
//  Model for glassmorphic visual effect parameters
//
//  ATOMIC RESPONSIBILITY: Data structure for glassmorphic styling
//  - Encapsulates visual effect parameters
//  - Provides GPU optimization flag
//  - Supports different shadow configurations
//  - Zero logic - pure data container
//

import Foundation
import SwiftUI

struct GlassmorphicEffectStyle: Codable {
    let backgroundOpacity: Double
    let borderGradient: BorderGradient
    let shadowEffect: ShadowEffect
    let gpuOptimized: Bool
    
    struct BorderGradient: Codable {
        let topOpacity: Double
        let bottomOpacity: Double
        let startPoint: UnitPoint
        let endPoint: UnitPoint
        
        init(topOpacity: Double, bottomOpacity: Double, 
             startPoint: UnitPoint = .top, endPoint: UnitPoint = .bottom) {
            self.topOpacity = topOpacity
            self.bottomOpacity = bottomOpacity
            self.startPoint = startPoint
            self.endPoint = endPoint
        }
    }
    
    struct ShadowEffect: Codable {
        let color: Color
        let radius: Double
        let opacity: Double
        let x: Double
        let y: Double
        
        init(color: Color, radius: Double, opacity: Double, x: Double = 0, y: Double = 0) {
            self.color = color
            self.radius = radius
            self.opacity = opacity
            self.x = x
            self.y = y
        }
    }
    
    // MARK: - Factory Methods
    
    /// Create default style from DesignTokens
    static func defaultStyle(from tokens: DesignTokens) -> GlassmorphicEffectStyle {
        return GlassmorphicEffectStyle(
            backgroundOpacity: tokens.glassmorphic.transparency.inputBackground,
            borderGradient: BorderGradient(
                topOpacity: tokens.glassmorphic.transparency.borderTop,
                bottomOpacity: tokens.glassmorphic.transparency.borderBottom
            ),
            shadowEffect: ShadowEffect(
                color: .black,
                radius: tokens.glassmorphic.shadows.outerShadow.radius,
                opacity: tokens.glassmorphic.shadows.outerShadow.opacity,
                x: tokens.glassmorphic.shadows.outerShadow.x,
                y: tokens.glassmorphic.shadows.outerShadow.y
            ),
            gpuOptimized: false
        )
    }
    
    /// Create GPU-optimized style with reduced effects
    static func optimizedStyle(from tokens: DesignTokens) -> GlassmorphicEffectStyle {
        return GlassmorphicEffectStyle(
            backgroundOpacity: tokens.glassmorphic.transparency.inputBackground,
            borderGradient: BorderGradient(
                topOpacity: tokens.glassmorphic.transparency.borderTop,
                bottomOpacity: tokens.glassmorphic.transparency.borderBottom
            ),
            shadowEffect: ShadowEffect(
                color: .black,
                radius: tokens.glassmorphic.shadows.outerShadow.radius * 0.5, // Reduced
                opacity: tokens.glassmorphic.shadows.outerShadow.opacity * 0.7, // Reduced
                x: 0,
                y: 2
            ),
            gpuOptimized: true
        )
    }
}

// MARK: - SwiftUI Extensions for Codable Support

extension Color: Codable {
    enum CodingKeys: String, CodingKey {
        case red, green, blue, opacity
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let red = try container.decode(Double.self, forKey: .red)
        let green = try container.decode(Double.self, forKey: .green)
        let blue = try container.decode(Double.self, forKey: .blue)
        let opacity = try container.decode(Double.self, forKey: .opacity)
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        // Default to black for encoding
        try container.encode(0.0, forKey: .red)
        try container.encode(0.0, forKey: .green)
        try container.encode(0.0, forKey: .blue)
        try container.encode(1.0, forKey: .opacity)
    }
}

extension UnitPoint: Codable {
    enum CodingKeys: String, CodingKey {
        case x, y
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(Double.self, forKey: .x)
        let y = try container.decode(Double.self, forKey: .y)
        self.init(x: x, y: y)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.x, forKey: .x)
        try container.encode(self.y, forKey: .y)
    }
}