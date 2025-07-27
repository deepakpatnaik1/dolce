//
//  DeleteCommand.swift
//  Aether
//
//  Model for delete command representation
//
//  ATOMIC RESPONSIBILITY: Pure data structure for delete commands
//  - Define delete command scope (last N turns or all)
//  - Hold command metadata
//  - Zero logic - pure data model
//

import Foundation

struct DeleteCommand {
    enum DeleteScope {
        case lastTurns(count: Int)
        case allTurns
    }
    
    let scope: DeleteScope
    let timestamp: Date
    
    init(scope: DeleteScope) {
        self.scope = scope
        self.timestamp = Date()
    }
}