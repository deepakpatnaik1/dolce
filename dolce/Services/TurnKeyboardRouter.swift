//
//  TurnKeyboardRouter.swift
//  Dolce
//
//  Atomic turn keyboard routing
//
//  ATOMIC RESPONSIBILITY: Route turn mode keyboard commands only
//  - Detect Option+Up/Down for turn navigation
//  - Detect Escape for turn mode exit
//  - Map key combinations to turn actions
//  - Zero navigation logic, zero turn logic, zero UI logic
//

import Foundation
import SwiftUI

struct TurnKeyboardRouter {
    
    enum TurnKeyboardAction {
        case navigateUp
        case navigateDown
        case exitTurnMode
        case ignore
    }
    
    /// Route keyboard input to turn actions
    static func routeKeyPress(_ keyPress: KeyPress) -> TurnKeyboardAction {
        print("[TurnKeyboardRouter] KeyPress - key: \(keyPress.key), modifiers: \(keyPress.modifiers)")
        
        // Option+Up Arrow: Navigate to previous turn
        if keyPress.key == .upArrow && keyPress.modifiers.contains(.option) {
            print("[TurnKeyboardRouter] Option+Up detected -> navigateUp")
            return .navigateUp
        }
        
        // Option+Down Arrow: Navigate to next turn
        if keyPress.key == .downArrow && keyPress.modifiers.contains(.option) {
            print("[TurnKeyboardRouter] Option+Down detected -> navigateDown")
            return .navigateDown
        }
        
        // Escape: Exit turn mode
        if keyPress.key == .escape {
            print("[TurnKeyboardRouter] Escape detected -> exitTurnMode")
            return .exitTurnMode
        }
        
        return .ignore
    }
    
    /// Check if key press should be handled by turn system
    static func shouldHandleTurnInput(_ keyPress: KeyPress) -> Bool {
        let action = routeKeyPress(keyPress)
        return action != .ignore
    }
}