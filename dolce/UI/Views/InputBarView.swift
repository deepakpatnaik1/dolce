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
    
    private let tokens = DesignTokens.shared
    
    init(conversationOrchestrator: ConversationOrchestrator) {
        self.conversationOrchestrator = conversationOrchestrator
        
        // Calculate single-line height for initial state
        let font = NSFont(name: DesignTokens.shared.typography.bodyFont, size: 12) ?? NSFont.systemFont(ofSize: 12)
        let lineHeight = font.ascender + abs(font.descender) + font.leading
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
                        // Handle regular Enter as new line
                    }
                    .onKeyPress(keys: [.return]) { keyPress in
                        if keyPress.modifiers.contains(.command) {
                            sendMessage()
                            return .handled
                        }
                        return .ignored
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
        }
    }
    
    private func updateTextHeight(for text: String) {
        let font = NSFont(name: tokens.typography.bodyFont, size: 12) ?? NSFont.systemFont(ofSize: 12)
        let lineHeight = font.ascender + abs(font.descender) + font.leading
        
        // Calculate actual line count
        let lineCount = getCurrentLineCount(for: text)
        let newHeight = CGFloat(lineCount) * lineHeight
        
        // Update height with smooth animation
        if abs(textHeight - newHeight) > 2 {
            withAnimation(.spring(response: 0.1, dampingFraction: 0.8, blendDuration: 0)) {
                textHeight = newHeight
            }
        } else {
            textHeight = newHeight
        }
    }
    
    private func getCurrentLineCount(for text: String) -> Int {
        let font = NSFont(name: tokens.typography.bodyFont, size: 12) ?? NSFont.systemFont(ofSize: 12)
        let contentWidth: CGFloat = tokens.layout.sizing["contentWidth"] ?? 592
        let textFieldWidth = contentWidth - (tokens.elements.inputBar.textPadding * 2)
        
        let height = measureTextHeight(for: text, width: textFieldWidth, font: font)
        let lineHeight = font.ascender + abs(font.descender) + font.leading
        
        return max(1, Int(ceil(height / lineHeight)))
    }
    
    private func measureTextHeight(for text: String, width: CGFloat, font: NSFont) -> CGFloat {
        let measureText = text.isEmpty ? "Ag" : text
        
        let attributedString = NSAttributedString(
            string: measureText,
            attributes: [
                .font: font,
                .paragraphStyle: {
                    let style = NSMutableParagraphStyle()
                    style.lineBreakMode = .byWordWrapping
                    return style
                }()
            ]
        )
        
        let boundingRect = attributedString.boundingRect(
            with: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading]
        )
        
        return ceil(boundingRect.height)
    }
}