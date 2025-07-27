//
//  GlassmorphicEffectRenderer.swift
//  Aether
//
//  Service for rendering GPU-safe glassmorphic effects
//
//  ATOMIC RESPONSIBILITY: Manage glassmorphic visual effects
//  - Determine GPU optimization requirements
//  - Create appropriate effect styles
//  - Monitor system performance
//  - Provide fallback for Metal shader issues
//

import Foundation
import SwiftUI
import Metal

@MainActor
class GlassmorphicEffectRenderer: ObservableObject {
    static let shared = GlassmorphicEffectRenderer()
    
    @Published private(set) var currentStyle: GlassmorphicEffectStyle
    private let tokens = DesignTokens.shared
    private var hasMetalWarning = false
    
    private init() {
        // Start with optimized style to avoid Metal warnings
        self.currentStyle = GlassmorphicEffectStyle.optimizedStyle(from: tokens)
    }
    
    // MARK: - Public Interface
    
    /// Create an optimized style based on current system state
    func createOptimizedStyle(from tokens: DesignTokens) -> GlassmorphicEffectStyle {
        if shouldUseGPUOptimization() {
            return GlassmorphicEffectStyle.optimizedStyle(from: tokens)
        } else {
            return GlassmorphicEffectStyle.defaultStyle(from: tokens)
        }
    }
    
    /// Determine if GPU optimization should be used
    func shouldUseGPUOptimization() -> Bool {
        // Check multiple factors
        let factors = [
            hasMetalWarning,
            !isMetalAvailable(),
            isLowPowerMode(),
            hasPerformanceIssues()
        ]
        
        // Use optimization if any factor is true
        return factors.contains(true)
    }
    
    /// Update the current style based on system state
    func updateStyle() {
        currentStyle = createOptimizedStyle(from: tokens)
    }
    
    /// Report Metal shader warning encountered
    func reportMetalWarning() {
        hasMetalWarning = true
        updateStyle()
    }
    
    // MARK: - Private Helpers
    
    /// Check if Metal is available on the system
    private func isMetalAvailable() -> Bool {
        return MTLCreateSystemDefaultDevice() != nil
    }
    
    /// Check if system is in low power mode
    private func isLowPowerMode() -> Bool {
        // macOS doesn't have a direct low power mode API
        // Could check battery state in the future
        return false
    }
    
    /// Check for performance issues
    private func hasPerformanceIssues() -> Bool {
        // Could monitor frame rates or system load
        // For now, return false
        return false
    }
    
    // MARK: - Style Presets
    
    /// Create a minimal style for maximum compatibility
    func createMinimalStyle() -> GlassmorphicEffectStyle {
        return GlassmorphicEffectStyle(
            backgroundOpacity: tokens.glassmorphic.transparency.inputBackground,
            borderGradient: GlassmorphicEffectStyle.BorderGradient(
                topOpacity: 0.1,
                bottomOpacity: 0.05
            ),
            shadowEffect: GlassmorphicEffectStyle.ShadowEffect(
                color: .clear,
                radius: 0,
                opacity: 0
            ),
            gpuOptimized: true
        )
    }
    
    /// Create style for specific component needs
    func createStyleForComponent(_ component: GlassmorphicComponent) -> GlassmorphicEffectStyle {
        switch component {
        case .inputBar:
            return currentStyle
        case .scrollback:
            // Could have different styles for different components
            return createOptimizedStyle(from: tokens)
        case .dragZone:
            return createMinimalStyle()
        }
    }
}

// MARK: - Component Types

enum GlassmorphicComponent {
    case inputBar
    case scrollback
    case dragZone
}