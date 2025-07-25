//
//  HeightAnimationEngine.swift
//  Dolce
//
//  Atomic height animation
//
//  ATOMIC RESPONSIBILITY: Animate height changes only
//  - Use spring physics with optimized parameters
//  - Performance threshold to avoid micro-animations
//  - Smooth organic breathing feel
//  - Zero text measurement, zero UI logic
//

import Foundation
import SwiftUI

struct HeightAnimationEngine {
    
    /// Animate height change with spring physics
    /// Uses design tokens for consistent animation parameters
    @MainActor
    static func animateHeightChange(
        from currentHeight: CGFloat,
        to targetHeight: CGFloat,
        update: @escaping (CGFloat) -> Void
    ) {
        animateHeightChange(
            from: currentHeight,
            to: targetHeight,
            animationId: nil,
            coordinator: nil,
            update: update
        )
    }
    
    /// Animate height change with optional animation tracking
    /// Supports cancellation via AnimationCoordinator
    @MainActor
    static func animateHeightChange(
        from currentHeight: CGFloat,
        to targetHeight: CGFloat,
        animationId: UUID? = nil,
        coordinator: AnimationCoordinator? = nil,
        update: @escaping (CGFloat) -> Void
    ) {
        let tokens = DesignTokens.shared
        let animationThreshold = CGFloat(tokens.animations.textExpansion.animationThreshold)
        
        // Performance threshold: only animate significant changes
        if abs(currentHeight - targetHeight) > animationThreshold {
            let response = tokens.animations.textExpansion.response
            let dampingFraction = tokens.animations.textExpansion.dampingFraction
            let blendDuration = tokens.animations.textExpansion.blendDuration
            
            let animation = Animation.spring(
                response: response,
                dampingFraction: dampingFraction,
                blendDuration: blendDuration
            )
            
            // Use coordinator if provided, otherwise use standard animation
            if let animationId = animationId, let coordinator = coordinator {
                coordinator.animateWithCancellation(
                    animationId,
                    value: targetHeight,
                    animation: animation
                ) { height in
                    update(height)
                }
            } else {
                withAnimation(animation) {
                    update(targetHeight)
                }
            }
        } else {
            // Direct update for small changes
            update(targetHeight)
        }
    }
    
    /// Check if height change warrants animation
    static func shouldAnimate(from currentHeight: CGFloat, to targetHeight: CGFloat) -> Bool {
        let tokens = DesignTokens.shared
        let animationThreshold = CGFloat(tokens.animations.textExpansion.animationThreshold)
        return abs(currentHeight - targetHeight) > animationThreshold
    }
}