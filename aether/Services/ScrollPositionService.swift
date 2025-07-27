//
//  ScrollPositionService.swift
//  Aether
//
//  Atomic service for scroll position persistence
//
//  ATOMIC RESPONSIBILITY: Save and load scroll position only
//  - Persists scroll position to vault
//  - Loads scroll position from vault
//  - Zero state management, zero UI logic
//  - Pure service with single responsibility
//

import Foundation

class ScrollPositionService {
    private let scrollStateFile = PathConfiguration.scrollPositionPath
    private let vaultReader: VaultReading
    private let vaultWriter: VaultWriting
    
    init(vaultReader: VaultReading = VaultReader.shared,
         vaultWriter: VaultWriting = VaultWriter.shared) {
        self.vaultReader = vaultReader
        self.vaultWriter = vaultWriter
    }
    
    /// Save scroll position to vault
    /// EXACT copy of logic from VaultStateManager
    func saveScrollPosition(_ position: CGFloat) {
        let state = ["scrollPosition": position]
        vaultWriter.writeJSON(state, to: scrollStateFile)
    }
    
    /// Load scroll position from vault
    /// EXACT copy of logic from VaultStateManager
    func loadScrollPosition() -> CGFloat? {
        let state = vaultReader.readJSON(at: scrollStateFile, as: [String: CGFloat].self)
        return state?["scrollPosition"]
    }
}