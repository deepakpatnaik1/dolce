//
//  JournalModeManager.swift
//  Dolce
//
//  Pure state management for journal mode
//
//  ATOMIC RESPONSIBILITY: Journal mode state validation only
//  - Validate entry/exit conditions
//  - Create state transitions
//  - Zero orchestration, zero UI logic
//  - Pure state management decisions
//

import Foundation

struct JournalModeManager {
    
    /// Check if journal mode can be entered
    func canEnterJournalMode() -> Bool {
        // Always allowed for now
        // Future: could check for existing drafts, permissions, etc.
        return true
    }
    
    /// Check if journal mode can be exited
    func canExitJournalMode(text: String) -> Bool {
        // Can only exit if text is empty
        return text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Create state for entering journal mode
    func createEnteringState(originalHeight: CGFloat, previousPersona: String) -> JournalModeState {
        return JournalModeState.entering(
            originalHeight: originalHeight,
            previousPersona: previousPersona
        )
    }
    
    /// Create state for exiting journal mode
    func createExitedState() -> JournalModeState {
        return JournalModeState.exited()
    }
}