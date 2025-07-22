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
    case turnNavigateUp
    case turnNavigateDown
    case turnModeExit
    case ignore
}

struct KeyboardCommandRouter {
    
    /// Route keyboard event to appropriate action
    static func routeKeyPress(_ keyPress: KeyPress) -> KeyboardAction {
        print("[KeyboardCommandRouter] KeyPress - key: \(keyPress.key), modifiers: \(keyPress.modifiers)")
        
        switch (keyPress.key, keyPress.modifiers) {
        case (.return, []):           // Enter alone → send message
            print("[KeyboardCommandRouter] Enter -> sendMessage")
            return .sendMessage
        case (.return, [.option]):    // Option+Enter → add new line
            print("[KeyboardCommandRouter] Option+Enter -> addNewLine")
            return .addNewLine
        case (.upArrow, let mods) where mods.contains(.option):   // Option+Up → navigate to previous turn
            print("[KeyboardCommandRouter] Option+Up -> turnNavigateUp")
            return .turnNavigateUp
        case (.downArrow, let mods) where mods.contains(.option): // Option+Down → navigate to next turn
            print("[KeyboardCommandRouter] Option+Down -> turnNavigateDown")
            return .turnNavigateDown
        case (.escape, []):           // Escape → exit turn mode
            print("[KeyboardCommandRouter] Escape -> turnModeExit")
            return .turnModeExit
        default:
            print("[KeyboardCommandRouter] Unhandled key combo -> ignore")
            return .ignore
        }
    }
    
    /// Check if key press should be handled by router
    static func shouldHandle(_ keyPress: KeyPress) -> Bool {
        return keyPress.key == .return || 
               keyPress.key == .escape || 
               (keyPress.key == .upArrow && keyPress.modifiers.contains(.option)) ||
               (keyPress.key == .downArrow && keyPress.modifiers.contains(.option))
    }
}