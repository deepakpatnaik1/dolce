//
//  TurnFilter.swift
//  Aether
//
//  Atomic turn message filtering
//
//  ATOMIC RESPONSIBILITY: Filter messages for turn display only
//  - Filter messages to show only current turn
//  - Convert turn index to message subset
//  - Handle turn mode vs normal mode display
//  - Zero turn logic, zero navigation logic, zero UI logic
//

import Foundation

struct TurnFilter {
    
    /// Filter messages for turn mode display
    /// Returns only the messages belonging to the specified turn
    @MainActor
    static func filterMessagesForTurn(
        _ messages: [ChatMessage],
        turnIndex: Int,
        isInTurnMode: Bool
    ) -> [ChatMessage] {
        // Normal mode: show all messages
        guard isInTurnMode else {
            return messages
        }
        
        // Turn mode: show only current turn
        let turns = TurnManager.shared.calculateTurns(from: messages)
        
        guard turnIndex >= 0 && turnIndex < turns.count else {
            return [] // Invalid turn index
        }
        
        let currentTurn = turns[turnIndex]
        var turnMessages: [ChatMessage] = [currentTurn.userMessage]
        
        if let aiMessage = currentTurn.aiMessage {
            turnMessages.append(aiMessage)
        }
        
        return turnMessages
    }
    
    /// Get display messages based on current turn mode state
    @MainActor
    static func getDisplayMessages(
        from messages: [ChatMessage],
        turnManager: TurnManager
    ) -> [ChatMessage] {
        return filterMessagesForTurn(
            messages,
            turnIndex: turnManager.currentTurnIndex,
            isInTurnMode: turnManager.isInTurnMode
        )
    }
    
    /// Check if messages should be filtered for turn display
    static func shouldFilterForTurnMode(isInTurnMode: Bool) -> Bool {
        return isInTurnMode
    }
}