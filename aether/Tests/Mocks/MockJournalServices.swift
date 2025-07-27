//
//  MockJournalServices.swift
//  Aether
//
//  Mock implementations of journal protocols for testing
//
//  ATOMIC RESPONSIBILITY: Provide test doubles for journal operations
//  - MockJournalManager: In-memory trim storage
//  - MockSuperjournalManager: In-memory turn storage
//  - Enables unit testing without file system dependencies
//  - Zero actual persistence
//

import Foundation

// MARK: - MockJournalManager

class MockJournalManager: JournalManaging {
    private var trims: [MachineTrim] = []
    
    /// Add a pre-existing trim for testing
    func addTrim(_ trim: MachineTrim) {
        trims.append(trim)
        // Keep sorted by timestamp
        trims.sort { $0.timestamp < $1.timestamp }
    }
    
    /// Clear all trims
    func reset() {
        trims.removeAll()
    }
    
    /// Get all saved trims (for verification)
    var savedTrims: [MachineTrim] {
        return trims
    }
    
    // MARK: - JournalManaging Implementation
    
    func saveTrim(_ trim: MachineTrim) {
        addTrim(trim)
    }
    
    func loadRecentTrims(limit: Int) -> [MachineTrim] {
        // Return most recent trims (sorted newest first)
        return Array(trims.reversed().prefix(limit))
    }
    
    func loadAllTrims() -> [MachineTrim] {
        return trims
    }
}

// MARK: - MockSuperjournalManager

class MockSuperjournalManager: SuperjournalManaging {
    private var turns: [(boss: String, persona: String, response: String, timestamp: Date)] = []
    
    /// Add a pre-existing turn for testing
    func addTurn(boss: String, persona: String, response: String, timestamp: Date = Date()) {
        turns.append((boss, persona, response, timestamp))
        // Keep sorted by timestamp
        turns.sort { $0.timestamp < $1.timestamp }
    }
    
    /// Clear all turns
    func reset() {
        turns.removeAll()
    }
    
    /// Get all saved turns (for verification)
    var savedTurns: [(boss: String, persona: String, response: String, timestamp: Date)] {
        return turns
    }
    
    // MARK: - SuperjournalManaging Implementation
    
    func saveFullTurn(boss: String, persona: String, response: String) {
        addTurn(boss: boss, persona: persona, response: response)
    }
    
    func loadAllTurns() -> [ChatMessage] {
        var messages: [ChatMessage] = []
        
        for turn in turns {
            // Create boss message
            let bossMessage = ChatMessage(
                id: UUID(),
                content: turn.boss,
                author: AuthorLabelProvider.getUserLabel(),
                timestamp: turn.timestamp,
                persona: nil
            )
            
            // Create persona message (1ms later to maintain order)
            let personaMessage = ChatMessage(
                id: UUID(),
                content: turn.response,
                author: turn.persona,
                timestamp: turn.timestamp.addingTimeInterval(0.001),
                persona: turn.persona
            )
            
            messages.append(bossMessage)
            messages.append(personaMessage)
        }
        
        return messages
    }
}