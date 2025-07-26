//
//  InputBarState.swift
//  Dolce
//
//  Pure UI state management for input bar
//
//  ATOMIC RESPONSIBILITY: Input bar UI state only
//  - Track text input state
//  - Manage text field height
//  - Handle focus state
//  - Zero business logic - pure state container
//

import Foundation
import SwiftUI

enum InputComponentType {
    case textField
    case textEditor
}

@MainActor
class InputBarState: ObservableObject {
    @Published var text: String = ""
    @Published var textHeight: CGFloat
    @Published var isFocused: Bool = false
    @Published var journalModeState = JournalModeState()
    @Published var textAlignment: Alignment = .center
    
    private let tokens = DesignTokens.shared
    private var debouncedCalculator: DebouncedHeightCalculator?
    private var animationCoordinator: AnimationCoordinator?
    private let currentAnimationId = UUID()
    
    init() {
        // Calculate actual height for empty text - no hardcoded values
        let font = NSFont(
            name: tokens.typography.bodyFont,
            size: CGFloat(tokens.elements.inputBar.fontSize)
        ) ?? NSFont.systemFont(ofSize: CGFloat(tokens.elements.inputBar.fontSize))
        
        let contentWidth: CGFloat = tokens.layout.sizing["contentWidth"] ?? 592
        let availableWidth = contentWidth - (tokens.elements.inputBar.textPadding * 2)
        
        // Calculate real height for empty string
        let calculatedHeight = TextMeasurementEngine.calculateHeight(
            for: "",
            font: font,
            availableWidth: availableWidth
        )
        self.textHeight = calculatedHeight
    }
    
    /// Configure with coordinator services
    func configure(debouncedCalculator: DebouncedHeightCalculator, animationCoordinator: AnimationCoordinator) {
        self.debouncedCalculator = debouncedCalculator
        self.animationCoordinator = animationCoordinator
    }
    
    // MARK: - State Management
    
    /// Clear input state after sending
    func clearInput() {
        text = ""
        // Only update height if not in journal mode
        if !journalModeState.isInJournalMode {
            updateHeight(for: "")
        }
    }
    
    /// Update text height based on content
    func updateHeight(for newText: String) {
        let font = NSFont(name: tokens.typography.bodyFont, size: CGFloat(tokens.elements.inputBar.fontSize)) ?? NSFont.systemFont(ofSize: CGFloat(tokens.elements.inputBar.fontSize))
        let contentWidth: CGFloat = tokens.layout.sizing["contentWidth"] ?? 592
        let availableWidth = contentWidth - (tokens.elements.inputBar.textPadding * 2)
        
        // Use debounced calculator if configured, otherwise fall back to direct calculation
        if let calculator = debouncedCalculator {
            calculator.calculateHeight(
                for: newText,
                font: font,
                availableWidth: availableWidth
            ) { [weak self] newHeight in
                guard let self = self else { return }
                
                // Use animation coordinator if available
                if let coordinator = self.animationCoordinator {
                    HeightAnimationEngine.animateHeightChange(
                        from: self.textHeight,
                        to: newHeight,
                        animationId: self.currentAnimationId,
                        coordinator: coordinator
                    ) { height in
                        self.textHeight = height
                    }
                } else {
                    HeightAnimationEngine.animateHeightChange(
                        from: self.textHeight,
                        to: newHeight
                    ) { height in
                        self.textHeight = height
                    }
                }
            }
        } else {
            // Fallback to direct calculation (maintains backward compatibility)
            let newHeight = TextMeasurementEngine.calculateHeight(
                for: newText,
                font: font,
                availableWidth: availableWidth
            )
            
            HeightAnimationEngine.animateHeightChange(
                from: textHeight,
                to: newHeight
            ) { [weak self] height in
                self?.textHeight = height
            }
        }
    }
    
    /// Check if input has content
    var hasText: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Get trimmed text content
    var trimmedText: String {
        text.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// Determine which input component to use based on mode
    var inputComponentType: InputComponentType {
        return journalModeState.isInJournalMode ? .textEditor : .textField
    }
}