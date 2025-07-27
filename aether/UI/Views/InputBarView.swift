//
//  InputBarView.swift
//  Aether
//
//  Pure UI component for text input with glassmorphic styling
//
//  ATOMIC RESPONSIBILITY: Input presentation only
//  - Render glassmorphic input interface using DesignTokens
//  - Display text field and control buttons
//  - Show attachment previews
//  - Zero business logic - pure presentation layer
//

import SwiftUI

struct InputBarView: View {
    @StateObject private var state = InputBarState()
    @FocusState private var isInputFocused: Bool
    @StateObject private var focusGuardian = FocusGuardian.shared
    
    @ObservedObject var fileDropHandler: FileDropHandler
    let coordinator: InputBarCoordinator
    
    private let tokens = DesignTokens.shared
    
    var body: some View {
        VStack(spacing: 0) {
            attachmentPreviewSection
            textInputSection
            bottomControlsSection
        }
        .glassmorphicBackground(
            style: coordinator.getGlassmorphicStyle(),
            cornerRadius: tokens.elements.inputBar.cornerRadius
        )
        .padding(.all, tokens.elements.inputBar.padding)
        .frame(width: tokens.layout.sizing["contentWidth"] ?? 592)
        .fixedSize(horizontal: false, vertical: true)
        .onAppear {
            isInputFocused = true
        }
    }
    
    // MARK: - Computed Properties for View Composition
    
    private var attachmentPreviewSection: some View {
        AttachmentPreviewArea(
            attachments: fileDropHandler.droppedFiles,
            onRemove: fileDropHandler.removeFile
        )
    }
    
    private var textInputSection: some View {
        ZStack(alignment: .bottomLeading) {
            textInputComponent
        }
    }
    
    @ViewBuilder
    private var textInputComponent: some View {
        Group {
            TextField("", text: $state.text, axis: .vertical)
                .font(.custom(tokens.typography.bodyFont, size: CGFloat(tokens.elements.inputBar.fontSize)))
                .foregroundColor(.white)
                .focused($isInputFocused)
                .textFieldStyle(PlainTextFieldStyle())
                .frame(minHeight: state.defaultHeight)
                .padding(.horizontal, tokens.elements.inputBar.textPadding)
                .padding(.top, tokens.elements.inputBar.topPadding)
                .padding(.bottom, tokens.elements.inputBar.topPadding)
                .onSubmit {
                    // Disabled - handled by onKeyPress
                }
                .onKeyPress { keyPress in
                    let action = KeyboardCommandRouter.routeKeyPress(keyPress)
                    
                    switch action {
                    case .sendMessage:
                        Task {
                            await coordinator.handleSendAction(text: state.text, state: state)
                        }
                        return .handled
                    case .addNewLine:
                        // Let TextField handle naturally for new line
                        return .ignored
                    case .turnNavigateUp, .turnNavigateDown, .turnModeExit:
                        // Delegate navigation and mode exits to coordinator
                        return coordinator.handleKeyboardCommand(action, state: state)
                    case .ignore:
                        return .ignored
                    }
                }
                .onChange(of: state.text) { oldValue, newValue in
                    // Handle text changes (height updates naturally)
                    coordinator.handleTextChange(newValue, state: state)
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
        .id("inputField")
    }
    
    private var bottomControlsSection: some View {
        HStack(spacing: tokens.elements.inputBar.controlsSpacing) {
            // Plus button - trigger file picker
            Button(action: {
                Task {
                    await coordinator.handleFilePickAction()
                }
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
            if state.hasText {
                Button(action: {
                    Task {
                        await coordinator.handleSendAction(text: state.text, state: state)
                    }
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
    
}