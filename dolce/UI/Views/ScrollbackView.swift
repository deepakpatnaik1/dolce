//
//  ScrollbackView.swift
//  Dolce
//
//  Pure UI component for displaying conversation messages
//
//  ATOMIC RESPONSIBILITY: Message display presentation only
//  - Render messages with glassmorphic styling using DesignTokens
//  - Handle persona-specific colors and author labels
//  - Fixed 592px width centered layout for Claude-inspired design
//  - Zero business logic - pure presentation layer
//

import SwiftUI

struct ScrollbackView: View {
    let messages: [ChatMessage]
    private let tokens = DesignTokens.shared
    @ObservedObject private var turnManager = TurnManager.shared
    
    // Computed property for display messages (turn-filtered)
    private var displayMessages: [ChatMessage] {
        return TurnFilter.getDisplayMessages(from: messages, turnManager: turnManager)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 0) {
                ForEach(Array(displayMessages.enumerated()), id: \.element.id) { index, message in
                    let showAuthor = shouldShowAuthor(at: index, in: displayMessages)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        // Author label with persona colors
                        if showAuthor {
                            authorLabel(for: message)
                        }
                        
                        // Message content
                        messageContent(message)
                            .padding(.bottom, isLastFromSpeaker(at: index, in: displayMessages) ? 16 : 4)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 20)
        }
        .frame(width: tokens.layout.sizing["contentWidth"] ?? 592)
        .scrollIndicators(.hidden)
    }
    
    // MARK: - Message Content
    
    @ViewBuilder
    private func messageContent(_ message: ChatMessage) -> some View {
        Text(message.content)
            .font(.custom(tokens.typography.bodyFont, size: tokens.elements.scrollback.bodyFontSize))
            .foregroundColor(.white)
            .multilineTextAlignment(.leading)
            .padding(.leading, 8)
    }
    
    // MARK: - Author Label
    
    @ViewBuilder
    private func authorLabel(for message: ChatMessage) -> some View {
        let accentColor = getPersonaColor(for: message)
        
        HStack(spacing: 0) {
            // Colored left border
            Rectangle()
                .fill(accentColor)
                .frame(width: 2)
            
            // Author name
            Text(message.displayAuthor)
                .font(.system(size: tokens.elements.scrollback.authorFontSize, weight: .medium))
                .foregroundColor(.white.opacity(0.85))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.05))
                )
            
            // Horizontal line with gradient fade (starts from right, tapers to left)
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [
                            accentColor.opacity(0.0),
                            accentColor.opacity(0.3),
                            accentColor.opacity(0.6)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
                .padding(.leading, 112)
        }
        .clipShape(RoundedRectangle(cornerRadius: 4))
        .padding(.top, 8)
        .padding(.bottom, 4)
        .padding(.leading, 8)
    }
    
    // MARK: - Helper Functions
    
    private func shouldShowAuthor(at index: Int, in messageArray: [ChatMessage]) -> Bool {
        guard index < messageArray.count else { return false }
        if index == 0 { return true }
        
        let currentMessage = messageArray[index]
        let previousMessage = messageArray[index - 1]
        return currentMessage.displayAuthor != previousMessage.displayAuthor
    }
    
    private func isLastFromSpeaker(at index: Int, in messageArray: [ChatMessage]) -> Bool {
        guard index < messageArray.count else { return true }
        if index == messageArray.count - 1 { return true }
        
        let currentMessage = messageArray[index]
        let nextMessage = messageArray[index + 1]
        return currentMessage.displayAuthor != nextMessage.displayAuthor
    }
    
    private func getPersonaColor(for message: ChatMessage) -> Color {
        let personaKey = message.isFromBoss ? "boss" : (message.persona?.lowercased() ?? "claude")
        
        guard let colorData = tokens.elements.scrollback.authorLabel.minimalBadge.accentColors[personaKey] else {
            let fallbackColor = tokens.elements.scrollback.fallbackColor
            return Color(
                red: fallbackColor.red,
                green: fallbackColor.green,
                blue: fallbackColor.blue
            )
        }
        
        return Color(
            red: colorData.red,
            green: colorData.green,
            blue: colorData.blue
        )
    }
}