//
//  TurnFilter.swift
//  Dolce
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
        print("[TurnFilter] Filtering messages - isInTurnMode: \(isInTurnMode), turnIndex: \(turnIndex), totalMessages: \(messages.count)")
        
        // Normal mode: show all messages
        guard isInTurnMode else {
            print("[TurnFilter] Not in turn mode - returning all \(messages.count) messages")
            return messages
        }
        
        // Turn mode: show only current turn
        let turns = TurnManager.shared.calculateTurns(from: messages)
        print("[TurnFilter] In turn mode - found \(turns.count) turns")
        
        guard turnIndex >= 0 && turnIndex < turns.count else {
            print("[TurnFilter] Invalid turn index \(turnIndex) for \(turns.count) turns")
            return [] // Invalid turn index
        }
        
        let currentTurn = turns[turnIndex]
        var turnMessages: [ChatMessage] = [currentTurn.userMessage]
        
        if let aiMessage = currentTurn.aiMessage {
            turnMessages.append(aiMessage)
        }
        
        print("[TurnFilter] Returning \(turnMessages.count) messages for turn \(turnIndex)")
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