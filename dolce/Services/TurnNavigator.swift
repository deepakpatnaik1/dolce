//
//  TurnNavigator.swift
//  Dolce
//
//  Atomic turn navigation
//
//  ATOMIC RESPONSIBILITY: Navigate between turns only
//  - Move to next/previous turn
//  - Handle turn boundary logic
//  - Calculate navigation direction
//  - Zero keyboard handling, zero UI logic, zero turn definition
//

import Foundation

struct TurnNavigator {
    
    enum NavigationDirection {
        case up      // Previous turn
        case down    // Next turn
    }
    
    enum NavigationResult {
        case moved(to: Int)
        case boundaryReached
        case noTurnsAvailable
    }
    
    /// Navigate to the next turn in specified direction
    static func navigate(
        from currentTurnIndex: Int,
        totalTurns: Int,
        direction: NavigationDirection
    ) -> NavigationResult {
        guard totalTurns > 0 else {
            return .noTurnsAvailable
        }
        
        let targetIndex: Int
        
        switch direction {
        case .up:
            targetIndex = currentTurnIndex - 1
        case .down:
            targetIndex = currentTurnIndex + 1
        }
        
        // Check boundaries
        if targetIndex < 0 || targetIndex >= totalTurns {
            return .boundaryReached
        }
        
        return .moved(to: targetIndex)
    }
    
    /// Navigate to latest turn (used when exiting turn mode)
    static func navigateToLatest(totalTurns: Int) -> NavigationResult {
        guard totalTurns > 0 else {
            return .noTurnsAvailable
        }
        
        let latestIndex = totalTurns - 1
        return .moved(to: latestIndex)
    }
    
    /// Navigate to first turn
    static func navigateToFirst() -> NavigationResult {
        return .moved(to: 0)
    }
}