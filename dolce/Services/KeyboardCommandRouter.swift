//
//  KeyboardCommandRouter.swift
//  Dolce
//
//  Atomic keyboard command routing
//
//  ATOMIC RESPONSIBILITY: Route keyboard events to actions only
//  - Map key combinations to specific commands
//  - Provide clean action enumeration
//  - Zero UI logic, zero business logic
//  - Pure event-to-action mapping
//

import Foundation
import SwiftUI

enum KeyboardAction {
    case sendMessage
    case addNewLine
    case ignore
}

struct KeyboardCommandRouter {
    
    /// Route keyboard event to appropriate action
    static func routeKeyPress(_ keyPress: KeyPress) -> KeyboardAction {
        switch (keyPress.key, keyPress.modifiers) {
        case (.return, []):           // Enter alone → send message
            return .sendMessage
        case (.return, [.option]):    // Option+Enter → add new line
            return .addNewLine
        default:
            return .ignore
        }
    }
    
    /// Check if key press should be handled by router
    static func shouldHandle(_ keyPress: KeyPress) -> Bool {
        return keyPress.key == .return
    }
}