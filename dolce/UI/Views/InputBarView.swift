//
//  InputBarView.swift
//  Dolce
//
//  Pure UI component for text input with glassmorphic styling
//
//  ATOMIC RESPONSIBILITY: Input presentation only
//  - Render glassmorphic input interface using DesignTokens
//  - Handle user text input events and dynamic height
//  - Provide clean input experience with send button
//  - Zero business logic - pure presentation layer
//

import SwiftUI

struct InputBarView: View {
    @State private var inputText: String = ""
    @State private var textHeight: CGFloat
    @FocusState private var isInputFocused: Bool
    @ObservedObject var conversationOrchestrator: ConversationOrchestrator
    @ObservedObject var messageStore: MessageStore
    @StateObject private var focusGuardian = FocusGuardian.shared
    @ObservedObject private var turnModeCoordinator = TurnModeCoordinator.shared
    
    private let tokens = DesignTokens.shared
    
    init(conversationOrchestrator: ConversationOrchestrator, messageStore: MessageStore) {
        self.conversationOrchestrator = conversationOrchestrator
        self.messageStore = messageStore
        
        // Calculate single-line height for initial state using TextMeasurementEngine
        let font = NSFont(name: DesignTokens.shared.typography.bodyFont, size: 12) ?? NSFont.systemFont(ofSize: 12)
        let lineHeight = TextMeasurementEngine.calculateLineHeight(for: font)
        _textHeight = State(initialValue: lineHeight)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Expandable text area
            ZStack(alignment: .bottomLeading) {
                TextField("", text: $inputText, axis: .vertical)
                    .font(.custom(tokens.typography.bodyFont, size: 12))
                    .foregroundColor(.white)
                    .focused($isInputFocused)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(height: textHeight)
                    .padding(.horizontal, tokens.elements.inputBar.textPadding)
                    .padding(.top, tokens.elements.inputBar.topPadding)
                    .padding(.bottom, tokens.elements.inputBar.topPadding)
                    .onSubmit {
                        // Disabled - handled by onKeyPress
                    }
                    .onKeyPress(keys: [.return, .escape, .upArrow, .downArrow]) { keyPress in
                        switch KeyboardCommandRouter.routeKeyPress(keyPress) {
                        case .sendMessage:
                            sendMessage()
                            return .handled
                        case .addNewLine:
                            // Let TextField handle naturally for new line
                            return .ignored
                        case .turnNavigateUp:
                            turnModeCoordinator.handleKeyboardCommand(.navigateUp, messages: messageStore.messages)
                            return .handled
                        case .turnNavigateDown:
                            turnModeCoordinator.handleKeyboardCommand(.navigateDown, messages: messageStore.messages)
                            return .handled
                        case .turnModeExit:
                            turnModeCoordinator.handleKeyboardCommand(.exitTurnMode, messages: messageStore.messages)
                            return .handled
                        case .ignore:
                            return .ignored
                        }
                    }
                    .onChange(of: focusGuardian.shouldFocusInput) { _, should in
                        if should { 
                            isInputFocused = true
                        }
                    }
                    .onChange(of: isInputFocused) { _, focused in
                        if focused { 
                            focusGuardian.inputDidReceiveFocus()
                        }
                    }
            }
            .onChange(of: inputText) { _, newValue in
                updateTextHeight(for: newValue)
            }
            
            // Bottom controls row
            HStack(spacing: tokens.elements.inputBar.controlsSpacing) {
                // Plus button
                Button(action: {
                    // TODO: Add attachment functionality
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(tokens.glassmorphic.transparency.controls))
                        .frame(width: tokens.elements.buttons.plusSize, height: tokens.elements.buttons.plusSize)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Model picker
                ModelPickerView()
                
                Spacer()
                
                // Send button (only show when text present)
                if !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: tokens.elements.buttons.sendSize, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Green indicator
                Circle()
                    .fill(Color.green)
                    .frame(width: tokens.elements.buttons.indicatorSize, height: tokens.elements.buttons.indicatorSize)
                    .shadow(color: .green, radius: tokens.glassmorphic.shadows.greenGlow.radius1, x: 0, y: 0)
                    .shadow(color: .green.opacity(tokens.glassmorphic.shadows.greenGlow.opacity), radius: tokens.glassmorphic.shadows.greenGlow.radius2, x: 0, y: 0)
            }
            .padding(.horizontal, tokens.elements.inputBar.textPadding)
            .padding(.bottom, tokens.elements.inputBar.bottomPadding)
            .padding(.top, 4)
        }
        .background(
            RoundedRectangle(cornerRadius: tokens.elements.inputBar.cornerRadius)
                .fill(Color.black.opacity(tokens.glassmorphic.transparency.inputBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: tokens.elements.inputBar.cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    .white.opacity(tokens.glassmorphic.transparency.borderTop),
                                    .white.opacity(tokens.glassmorphic.transparency.borderBottom)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(
                    color: .white.opacity(tokens.glassmorphic.shadows.innerGlow.opacity),
                    radius: tokens.glassmorphic.shadows.innerGlow.radius,
                    x: tokens.glassmorphic.shadows.innerGlow.x,
                    y: tokens.glassmorphic.shadows.innerGlow.y
                )
                .shadow(
                    color: .black.opacity(tokens.glassmorphic.shadows.outerShadow.opacity),
                    radius: tokens.glassmorphic.shadows.outerShadow.radius,
                    x: tokens.glassmorphic.shadows.outerShadow.x,
                    y: tokens.glassmorphic.shadows.outerShadow.y
                )
        )
        .padding(.all, tokens.elements.inputBar.padding)
        .frame(width: tokens.layout.sizing["contentWidth"] ?? 592)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            isInputFocused = true
        }
    }
    
    // MARK: - Private Functions
    
    private func sendMessage() {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let messageToSend = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = ""
        
        Task {
            await conversationOrchestrator.sendMessage(messageToSend)
            
            // Handle turn mode: if in turn mode, move to latest turn to show new conversation
            if TurnManager.shared.isInTurnMode {
                turnModeCoordinator.handleNewMessageInTurnMode(messages: messageStore.messages)
            }
        }
    }
    
    private func updateTextHeight(for text: String) {
        let font = NSFont(name: tokens.typography.bodyFont, size: 12) ?? NSFont.systemFont(ofSize: 12)
        let contentWidth: CGFloat = tokens.layout.sizing["contentWidth"] ?? 592
        let availableWidth = contentWidth - (tokens.elements.inputBar.textPadding * 2)
        
        // Use TextMeasurementEngine for height calculation
        let newHeight = TextMeasurementEngine.calculateHeight(
            for: text,
            font: font, 
            availableWidth: availableWidth
        )
        
        // Use HeightAnimationEngine for smooth animation
        HeightAnimationEngine.animateHeightChange(
            from: textHeight,
            to: newHeight
        ) { [self] height in
            textHeight = height
        }
    }
}