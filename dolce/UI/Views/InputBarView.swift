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
    @ObservedObject var fileDropHandler: FileDropHandler
    @StateObject private var focusGuardian = FocusGuardian.shared
    @ObservedObject private var turnModeCoordinator = TurnModeCoordinator.shared
    
    private let tokens = DesignTokens.shared
    
    init(conversationOrchestrator: ConversationOrchestrator, messageStore: MessageStore, fileDropHandler: FileDropHandler) {
        self.conversationOrchestrator = conversationOrchestrator
        self.messageStore = messageStore
        self.fileDropHandler = fileDropHandler
        
        // Calculate single-line height for initial state using TextMeasurementEngine
        let font = NSFont(name: DesignTokens.shared.typography.bodyFont, size: 12) ?? NSFont.systemFont(ofSize: 12)
        let lineHeight = TextMeasurementEngine.calculateLineHeight(for: font)
        _textHeight = State(initialValue: lineHeight)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            attachmentPreviewSection
            textInputSection
            bottomControlsSection
        }
        .background(glassmorphicBackground)
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
                .onKeyPress { keyPress in
                    switch KeyboardCommandRouter.routeKeyPress(keyPress) {
                    case .sendMessage:
                        sendMessage()
                        return .handled
                    case .addNewLine:
                        // Let TextField handle naturally for new line
                        return .ignored
                    case .turnNavigateUp:
                        turnModeCoordinator.handleKeyboardCommand(TurnKeyboardRouter.TurnKeyboardAction.navigateUp, messages: messageStore.messages)
                        return .handled
                    case .turnNavigateDown:
                        turnModeCoordinator.handleKeyboardCommand(TurnKeyboardRouter.TurnKeyboardAction.navigateDown, messages: messageStore.messages)
                        return .handled
                    case .turnModeExit:
                        turnModeCoordinator.handleKeyboardCommand(TurnKeyboardRouter.TurnKeyboardAction.exitTurnMode, messages: messageStore.messages)
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
    }
    
    private var bottomControlsSection: some View {
        HStack(spacing: tokens.elements.inputBar.controlsSpacing) {
            // Plus button - trigger file picker
            Button(action: {
                openFilePicker()
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
    
    private var glassmorphicBackground: some View {
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
    }
    
    // MARK: - Private Functions
    
    private func sendMessage() {
        let trimmedText = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasText = !trimmedText.isEmpty
        let hasFiles = !fileDropHandler.droppedFiles.isEmpty
        
        guard hasText || hasFiles else { return }
        
        // Prepare message content
        var messageContent = trimmedText
        
        // Add file content if present
        if hasFiles {
            let fileContent = FileProcessor.processFilesForChat(fileDropHandler.droppedFiles)
            if hasText {
                messageContent = "\(trimmedText)\n\n\(fileContent)"
            } else {
                messageContent = FileProcessor.generateChatSummary(fileDropHandler.droppedFiles) + "\n\n\(fileContent)"
            }
        }
        
        // Clear input and files
        inputText = ""
        let attachments = fileDropHandler.droppedFiles
        fileDropHandler.clearFiles()
        
        Task {
            await conversationOrchestrator.sendMessageWithAttachments(messageContent, attachments: attachments)
            
            // Handle turn mode: if in turn mode, move to latest turn to show new conversation
            if TurnManager.shared.isInTurnMode {
                turnModeCoordinator.handleNewMessageInTurnMode(messages: messageStore.messages)
            }
        }
    }
    
    private func openFilePicker() {
        let panel = NSOpenPanel()
        panel.allowsMultipleSelection = true
        panel.canChooseDirectories = false
        panel.canChooseFiles = true
        panel.allowedContentTypes = [.image, .pdf, .plainText, .sourceCode, .json]
        
        if panel.runModal() == .OK {
            for url in panel.urls {
                if let data = try? Data(contentsOf: url) {
                    let name = url.lastPathComponent
                    let size = Int64(data.count)
                    let fileType = DroppedFile.FileType.from(filename: name)
                    
                    // Check file size (10MB limit)
                    if size <= 10 * 1024 * 1024 {
                        let previewText = extractPreviewText(from: data, type: fileType)
                        let droppedFile = DroppedFile(
                            name: name,
                            type: fileType,
                            size: size,
                            data: data,
                            previewText: previewText
                        )
                        fileDropHandler.addFile(droppedFile)
                    }
                }
            }
        }
    }
    
    private func extractPreviewText(from data: Data, type: DroppedFile.FileType) -> String? {
        switch type {
        case .text, .markdown, .code:
            return String(data: data, encoding: .utf8) ?? String(data: data, encoding: .ascii)
        case .image:
            return "Image file (\(data.count) bytes)"
        case .pdf:
            return "PDF document (\(data.count) bytes)"
        case .unknown:
            return "Binary file (\(data.count) bytes)"
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