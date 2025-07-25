//
//  AnimationCoordinator.swift
//  Dolce
//
//  Animation lifecycle management service
//
//  ATOMIC RESPONSIBILITY: Coordinate animation lifecycle
//  - Track active animations by ID
//  - Cancel previous animations before starting new ones
//  - Prevent animation pile-up
//  - Manage animation completion callbacks
//

import Foundation
import SwiftUI

@MainActor
class AnimationCoordinator: ObservableObject {
    private var activeAnimations: Set<UUID> = []
    private var completionHandlers: [UUID: () -> Void] = [:]
    
    /// Start a new animation, cancelling any previous ones for the same context
    func animateWithCancellation<T>(
        _ animationId: UUID,
        value: T,
        animation: Animation,
        onChange: @escaping (T) -> Void
    ) where T: Equatable {
        print("🎬 Animation: Starting animation \(animationId)")
        
        // Cancel all active animations
        if !activeAnimations.isEmpty {
            print("❌ Animation: Cancelling \(activeAnimations.count) active animations")
        }
        cancelAllAnimations()
        
        // Mark this animation as active
        activeAnimations.insert(animationId)
        
        // Perform the animation
        withAnimation(animation) {
            onChange(value)
        }
        
        // Schedule cleanup after animation duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            print("✅ Animation: Completed animation \(animationId)")
            self?.completeAnimation(animationId)
        }
    }
    
    /// Cancel a specific animation
    func cancelAnimation(_ animationId: UUID) {
        activeAnimations.remove(animationId)
        completionHandlers.removeValue(forKey: animationId)
    }
    
    /// Cancel all active animations
    func cancelAllAnimations() {
        activeAnimations.removeAll()
        completionHandlers.removeAll()
    }
    
    /// Mark an animation as complete
    private func completeAnimation(_ animationId: UUID) {
        activeAnimations.remove(animationId)
        
        // Execute completion handler if any
        if let handler = completionHandlers.removeValue(forKey: animationId) {
            handler()
        }
    }
    
    /// Check if an animation is currently active
    func isAnimating(_ animationId: UUID) -> Bool {
        activeAnimations.contains(animationId)
    }
    
    /// Check if any animations are active
    var hasActiveAnimations: Bool {
        !activeAnimations.isEmpty
    }
    
    /// Register a completion handler for an animation
    func onAnimationComplete(_ animationId: UUID, handler: @escaping () -> Void) {
        completionHandlers[animationId] = handler
    }
}