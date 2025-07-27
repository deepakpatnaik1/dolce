//
//  GlassmorphicBackground.swift
//  Aether
//
//  Reusable glassmorphic background component
//
//  ATOMIC RESPONSIBILITY: Render glassmorphic visual effects
//  - Display background with transparency
//  - Apply gradient borders
//  - Render GPU-safe shadows
//  - Zero business logic - pure presentation
//

import SwiftUI

struct GlassmorphicBackground: View {
    let style: GlassmorphicEffectStyle
    let cornerRadius: Double
    
    init(style: GlassmorphicEffectStyle, cornerRadius: Double = 12) {
        self.style = style
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        if style.gpuOptimized {
            optimizedBackground
        } else {
            fullEffectBackground
        }
    }
    
    // MARK: - Background Variants
    
    /// Full effect background with all visual features
    private var fullEffectBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.black.opacity(style.backgroundOpacity))
            .overlay(borderOverlay)
            .shadow(
                color: style.shadowEffect.color.opacity(style.shadowEffect.opacity),
                radius: style.shadowEffect.radius,
                x: style.shadowEffect.x,
                y: style.shadowEffect.y
            )
    }
    
    /// GPU-optimized background with reduced effects
    private var optimizedBackground: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.black.opacity(style.backgroundOpacity))
            .overlay(borderOverlay)
            // Single, simplified shadow
            .shadow(
                color: style.shadowEffect.color.opacity(style.shadowEffect.opacity),
                radius: style.shadowEffect.radius,
                x: style.shadowEffect.x,
                y: style.shadowEffect.y
            )
    }
    
    /// Border overlay with gradient
    private var borderOverlay: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .stroke(
                LinearGradient(
                    colors: [
                        Color.white.opacity(style.borderGradient.topOpacity),
                        Color.white.opacity(style.borderGradient.bottomOpacity)
                    ],
                    startPoint: style.borderGradient.startPoint,
                    endPoint: style.borderGradient.endPoint
                ),
                lineWidth: 1
            )
    }
}

// MARK: - View Modifiers

extension View {
    /// Apply glassmorphic background using the shared renderer
    func glassmorphicBackground(
        component: GlassmorphicComponent = .inputBar,
        cornerRadius: Double = 12
    ) -> some View {
        self.background(
            GlassmorphicBackground(
                style: GlassmorphicEffectRenderer.shared.createStyleForComponent(component),
                cornerRadius: cornerRadius
            )
        )
    }
    
    /// Apply glassmorphic background with custom style
    func glassmorphicBackground(
        style: GlassmorphicEffectStyle,
        cornerRadius: Double = 12
    ) -> some View {
        self.background(
            GlassmorphicBackground(
                style: style,
                cornerRadius: cornerRadius
            )
        )
    }
}

// MARK: - Preview Support

#if DEBUG
struct GlassmorphicBackground_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // Default style
            Text("Default Glassmorphic Style")
                .padding()
                .glassmorphicBackground()
            
            // Optimized style
            Text("GPU Optimized Style")
                .padding()
                .glassmorphicBackground(
                    style: GlassmorphicEffectStyle.optimizedStyle(from: DesignTokens.shared)
                )
        }
        .padding()
        .background(Color.gray.opacity(0.3))
    }
}
#endif