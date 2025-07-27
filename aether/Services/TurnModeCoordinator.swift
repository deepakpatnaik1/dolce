//
//  TurnModeCoordinator.swift
//  Aether
//
//  Atomic turn mode coordination
//
//  ATOMIC RESPONSIBILITY: Coordinate turn mode operations only
//  - Handle turn mode entry/exit
//  - Coordinate navigation between atomic components
//  - Process keyboard commands for turn mode
//  - Zero keyboard detection, zero filtering, zero navigation logic
//

import Foundation

@MainActor
final class TurnModeCoordinator: ObservableObject {
    static let shared = TurnModeCoordinator()
    
    private let turnManager = TurnManager.shared
    
    private init() {}
    
    // MARK: - Turn Mode Operations
    
    /// Enter turn mode starting at latest turn
    func enterTurnMode(messages: [ChatMessage]) {
        let turns = turnManager.calculateTurns(from: messages)
        guard !turns.isEmpty else { return }
        
        turnManager.enterTurnMode(startingAtLatest: turns.count)
    }
    
    /// Exit turn mode and return to normal view
    func exitTurnMode() {
        turnManager.exitTurnMode()
    }
    
    /// Handle keyboard command for turn mode
    func handleKeyboardCommand(_ action: TurnKeyboardRouter.TurnKeyboardAction, messages: [ChatMessage]) {
        switch action {
        case .navigateUp:
            navigateUp(messages: messages)
        case .navigateDown:
            navigateDown(messages: messages)
        case .exitTurnMode:
            exitTurnMode()
        case .ignore:
            break // No action needed
        }
    }
    
    /// Handle new message submission while in turn mode
    func handleNewMessageInTurnMode(messages: [ChatMessage]) {
        // Stay in turn mode, but move to latest turn to show new conversation
        let turns = turnManager.calculateTurns(from: messages)
        guard !turns.isEmpty else { return }
        
        turnManager.setTurnIndex(turns.count - 1, totalTurns: turns.count)
    }
    
    // MARK: - Private Navigation Coordination
    
    private func navigateUp(messages: [ChatMessage]) {
        // If not in turn mode, enter turn mode at latest turn first
        if !turnManager.isInTurnMode {
            enterTurnMode(messages: messages)
            return
        }
        
        // Already in turn mode - navigate up
        let turns = turnManager.calculateTurns(from: messages)
        
        let result = TurnNavigator.navigate(
            from: turnManager.currentTurnIndex,
            totalTurns: turns.count,
            direction: .up
        )
        
        switch result {
        case .moved(let newIndex):
            turnManager.setTurnIndex(newIndex, totalTurns: turns.count)
        case .boundaryReached, .noTurnsAvailable:
            break // Stay at current position
        }
    }
    
    private func navigateDown(messages: [ChatMessage]) {
        let turns = turnManager.calculateTurns(from: messages)
        
        let result = TurnNavigator.navigate(
            from: turnManager.currentTurnIndex,
            totalTurns: turns.count,
            direction: .down
        )
        
        switch result {
        case .moved(let newIndex):
            turnManager.setTurnIndex(newIndex, totalTurns: turns.count)
        case .boundaryReached, .noTurnsAvailable:
            break // Stay at current position
        }
    }
}