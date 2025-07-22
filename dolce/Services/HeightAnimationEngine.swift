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
    /// Uses aether's proven parameters: 0.1 response, 0.8 damping
    static func animateHeightChange(
        from currentHeight: CGFloat,
        to targetHeight: CGFloat,
        update: @escaping (CGFloat) -> Void
    ) {
        // Performance threshold: only animate significant changes
        if abs(currentHeight - targetHeight) > 2 {
            withAnimation(.spring(
                response: 0.1,      // Fast response
                dampingFraction: 0.8, // Well-damped
                blendDuration: 0     // No blend transition
            )) {
                update(targetHeight)
            }
        } else {
            // Direct update for small changes
            update(targetHeight)
        }
    }
    
    /// Check if height change warrants animation
    static func shouldAnimate(from currentHeight: CGFloat, to targetHeight: CGFloat) -> Bool {
        return abs(currentHeight - targetHeight) > 2
    }
}