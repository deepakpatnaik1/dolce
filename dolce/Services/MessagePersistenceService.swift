//
//  MessagePersistenceService.swift
//  Dolce
//
//  Atomic service for message persistence operations
//
//  ATOMIC RESPONSIBILITY: Load persisted messages only
//  - Loads conversation history from superjournal
//  - Returns array of ChatMessage for UI display
//  - Zero state management, zero UI logic
//  - Pure service with single responsibility
//

import Foundation

class MessagePersistenceService {
    private let superjournalManager: SuperjournalManaging
    
    init(superjournalManager: SuperjournalManaging = SuperjournalManager.shared) {
        self.superjournalManager = superjournalManager
    }
    
    /// Load persisted messages from superjournal
    /// EXACT copy of logic from MessageStore
    func loadPersistedMessages() -> [ChatMessage] {
        return superjournalManager.loadAllTurns()
    }
}