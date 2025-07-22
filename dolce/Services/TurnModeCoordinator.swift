//
//  TurnModeCoordinator.swift
//  Dolce
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
        print("[TurnModeCoordinator] Handling keyboard command: \(action)")
        
        switch action {
        case .navigateUp:
            print("[TurnModeCoordinator] Processing navigateUp")
            navigateUp(messages: messages)
        case .navigateDown:
            print("[TurnModeCoordinator] Processing navigateDown")
            navigateDown(messages: messages)
        case .exitTurnMode:
            print("[TurnModeCoordinator] Processing exitTurnMode")
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
        print("[TurnModeCoordinator] navigateUp - isInTurnMode: \(turnManager.isInTurnMode)")
        
        // If not in turn mode, enter turn mode at latest turn first
        if !turnManager.isInTurnMode {
            print("[TurnModeCoordinator] Not in turn mode, entering turn mode")
            enterTurnMode(messages: messages)
            return
        }
        
        // Already in turn mode - navigate up
        let turns = turnManager.calculateTurns(from: messages)
        print("[TurnModeCoordinator] Already in turn mode - currentIndex: \(turnManager.currentTurnIndex), totalTurns: \(turns.count)")
        
        let result = TurnNavigator.navigate(
            from: turnManager.currentTurnIndex,
            totalTurns: turns.count,
            direction: .up
        )
        
        print("[TurnModeCoordinator] Navigation result: \(result)")
        
        switch result {
        case .moved(let newIndex):
            print("[TurnModeCoordinator] Moving to turn index: \(newIndex)")
            turnManager.setTurnIndex(newIndex, totalTurns: turns.count)
        case .boundaryReached, .noTurnsAvailable:
            print("[TurnModeCoordinator] Navigation boundary reached or no turns available")
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