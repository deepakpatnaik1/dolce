//
//  JournalProtocols.swift
//  Dolce
//
//  Protocol definitions for journal services
//
//  ATOMIC RESPONSIBILITY: Define contracts for journal operations
//  - JournalManaging: Machine trim storage and retrieval
//  - SuperjournalManaging: Full conversation turn storage
//  - Enables dependency injection and testing
//  - Zero implementation, pure interface definition
//

import Foundation

// MARK: - JournalManaging Protocol

/// Protocol for machine trim journal operations
protocol JournalManaging {
    /// Save a machine trim to the journal
    func saveTrim(_ trim: MachineTrim)
    
    /// Load recent trims with a limit
    func loadRecentTrims(limit: Int) -> [MachineTrim]
    
    /// Load all trims from the journal
    func loadAllTrims() -> [MachineTrim]
}

// MARK: - SuperjournalManaging Protocol

/// Protocol for full conversation turn operations
protocol SuperjournalManaging {
    /// Save a full conversation turn
    func saveFullTurn(boss: String, persona: String, response: String)
    
    /// Load all conversation turns as chat messages
    func loadAllTurns() -> [ChatMessage]
}