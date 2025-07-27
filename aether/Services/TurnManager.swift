//
//  TurnManager.swift
//  Aether
//
//  Atomic turn management
//
//  ATOMIC RESPONSIBILITY: Define and track turns only
//  - Define what constitutes a conversation turn
//  - Track current turn index
//  - Calculate turn boundaries from message array
//  - Zero navigation logic, zero UI logic, zero keyboard handling
//

import Foundation

@MainActor
final class TurnManager: ObservableObject {
    static let shared = TurnManager()
    
    @Published private(set) var currentTurnIndex: Int = 0
    @Published private(set) var isInTurnMode: Bool = false
    @Published private(set) var totalTurns: Int = 0
    
    private init() {}
    
    // MARK: - Turn Definition
    
    /// A conversation turn: user message + AI response (if exists)
    struct Turn {
        let userMessage: ChatMessage
        let aiMessage: ChatMessage?
        let turnIndex: Int
    }
    
    /// Calculate turns from message array
    /// Turn = User message + optional AI response that follows
    func calculateTurns(from messages: [ChatMessage]) -> [Turn] {
        var turns: [Turn] = []
        var turnIndex = 0
        var i = 0
        
        while i < messages.count {
            let currentMessage = messages[i]
            
            // Look for user messages to start turns
            if currentMessage.isFromBoss {
                let userMessage = currentMessage
                var aiMessage: ChatMessage? = nil
                
                // Check if next message is AI response
                if i + 1 < messages.count && !messages[i + 1].isFromBoss {
                    aiMessage = messages[i + 1]
                    i += 1 // Skip the AI message in next iteration
                }
                
                let turn = Turn(
                    userMessage: userMessage,
                    aiMessage: aiMessage,
                    turnIndex: turnIndex
                )
                turns.append(turn)
                turnIndex += 1
            }
            
            i += 1
        }
        
        return turns
    }
    
    // MARK: - Turn Index Management
    
    func setTurnIndex(_ index: Int, totalTurns: Int) {
        let clampedIndex = max(0, min(index, totalTurns - 1))
        DispatchQueue.main.async {
            self.currentTurnIndex = clampedIndex
            self.totalTurns = totalTurns
        }
    }
    
    func enterTurnMode(startingAtLatest totalTurns: Int) {
        DispatchQueue.main.async {
            self.isInTurnMode = true
            self.totalTurns = totalTurns
            // Start at latest turn (last index)
            self.currentTurnIndex = max(0, totalTurns - 1)
        }
    }
    
    func exitTurnMode() {
        DispatchQueue.main.async {
            self.isInTurnMode = false
            self.currentTurnIndex = 0
            self.totalTurns = 0
        }
    }
    
    // MARK: - Turn Information
    
    var isAtFirstTurn: Bool {
        return currentTurnIndex == 0
    }
    
    var isAtLastTurn: Bool {
        return currentTurnIndex == totalTurns - 1
    }
}