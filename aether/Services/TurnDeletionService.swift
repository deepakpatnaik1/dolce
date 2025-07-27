//
//  TurnDeletionService.swift
//  Aether
//
//  Service for executing turn deletion operations
//
//  ATOMIC RESPONSIBILITY: Delete turns from storage
//  - Move journal/superjournal files to trash
//  - Find files by turn timestamps
//  - Return deleted file count
//  - Zero UI logic, pure file operations
//

import Foundation

@MainActor
struct TurnDeletionService {
    private let fileManager = FileManager.default
    private let vaultPath: String
    private let journalManager: JournalManaging
    private let superjournalManager: SuperjournalManaging
    
    init(vaultPath: String,
         journalManager: JournalManaging = JournalManager.shared,
         superjournalManager: SuperjournalManaging = SuperjournalManager.shared) {
        self.vaultPath = vaultPath
        self.journalManager = journalManager
        self.superjournalManager = superjournalManager
    }
    
    /// Delete turns based on command scope
    /// Returns tuple of (journalDeletedCount, superjournalDeletedCount)
    func deleteTurns(command: DeleteCommand, from messages: [ChatMessage]) -> (journal: Int, superjournal: Int) {
        let turns = TurnManager.shared.calculateTurns(from: messages)
        let turnsToDelete = selectTurnsToDelete(command: command, from: turns)
        
        var journalDeleted = 0
        var superjournalDeleted = 0
        
        for turn in turnsToDelete {
            // Delete journal files
            if deleteJournalFile(for: turn) {
                journalDeleted += 1
            }
            
            // Delete superjournal files
            if deleteSuperJournalFile(for: turn) {
                superjournalDeleted += 1
            }
        }
        
        return (journalDeleted, superjournalDeleted)
    }
    
    private func selectTurnsToDelete(command: DeleteCommand, from turns: [TurnManager.Turn]) -> [TurnManager.Turn] {
        switch command.scope {
        case .allTurns:
            return turns
        case .lastTurns(let count):
            return Array(turns.suffix(count))
        }
    }
    
    private func deleteJournalFile(for turn: TurnManager.Turn) -> Bool {
        // Use same date format as MachineTrim
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        let timestamp = formatter.string(from: turn.userMessage.timestamp)
        
        let journalFileName = "Trim-\(timestamp).md"
        let journalPath = "\(vaultPath)/journal/\(journalFileName)"
        
        return moveToTrash(filePath: journalPath, originalName: journalFileName)
    }
    
    private func deleteSuperJournalFile(for turn: TurnManager.Turn) -> Bool {
        // Use same date format as SuperjournalManager
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        let timestamp = formatter.string(from: turn.userMessage.timestamp)
        
        let superJournalFileName = "FullTurn-\(timestamp).md"
        let superJournalPath = "\(vaultPath)/superjournal/\(superJournalFileName)"
        
        return moveToTrash(filePath: superJournalPath, originalName: superJournalFileName)
    }
    
    private func moveToTrash(filePath: String, originalName: String) -> Bool {
        guard fileManager.fileExists(atPath: filePath) else {
            // File doesn't exist - not an error, just skip
            return false
        }
        
        let trashPath = "\(vaultPath)/trash"
        createDirectoryIfNeeded(at: trashPath)
        
        // Use same date format for deletion timestamp
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd-HHmm"
        let deletionTimestamp = formatter.string(from: Date())
        
        let trashedFileName = "Deleted-\(deletionTimestamp)-\(originalName)"
        let destination = "\(trashPath)/\(trashedFileName)"
        
        do {
            try fileManager.moveItem(atPath: filePath, toPath: destination)
            return true
        } catch {
            // Log error but don't crash - file operations can fail
            print("TurnDeletionService: Failed to move \(filePath) to trash: \(error)")
            return false
        }
    }
    
    private func createDirectoryIfNeeded(at path: String) {
        if !fileManager.fileExists(atPath: path) {
            try? fileManager.createDirectory(atPath: path, withIntermediateDirectories: true)
        }
    }
}