//
//  FocusGuardian.swift
//  Dolce
//
//  Atomic focus management
//
//  ATOMIC RESPONSIBILITY: Maintain input bar focus only
//  - Monitor app activation state
//  - Ensure input bar stays focused when app is active
//  - Zero UI logic, zero business logic
//

import Foundation
import AppKit
import SwiftUI

@MainActor
final class FocusGuardian: ObservableObject {
    static let shared = FocusGuardian()
    
    @Published private(set) var shouldFocusInput = true
    
    private var appStateObserver: NSObjectProtocol?
    
    private init() {
        setupAppStateMonitoring()
    }
    
    private func setupAppStateMonitoring() {
        appStateObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.shouldFocusInput = true
        }
    }
    
    func inputDidReceiveFocus() {
        shouldFocusInput = false
    }
    
    deinit {
        if let observer = appStateObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
}