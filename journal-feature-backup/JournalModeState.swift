//
//  JournalModeState.swift
//  Aether
//
//  Model for tracking journal mode state
//
//  ATOMIC RESPONSIBILITY: Track journal mode UI state
//  - Store journal mode active state
//  - Remember original height for restoration
//  - Track entry timestamp
//  - Zero logic - pure state container
//

import Foundation

struct JournalModeState {
    var isInJournalMode: Bool = false
    var originalHeight: CGFloat = 0
    var enteredAt: Date?
    var previousPersona: String?
    
    /// Create journal mode state for entering journal mode
    static func entering(originalHeight: CGFloat, previousPersona: String) -> JournalModeState {
        return JournalModeState(
            isInJournalMode: true,
            originalHeight: originalHeight,
            enteredAt: Date(),
            previousPersona: previousPersona
        )
    }
    
    /// Reset to default state when exiting journal mode
    static func exited() -> JournalModeState {
        return JournalModeState()
    }
}