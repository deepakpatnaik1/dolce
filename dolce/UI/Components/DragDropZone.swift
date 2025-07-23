//
//  DragDropZone.swift
//  Dolce
//
//  Pure UI component for drag-drop visual feedback
//
//  ATOMIC RESPONSIBILITY: Drop zone presentation only
//  - Show glassmorphic overlay during drag operations
//  - Visual feedback for drop states using DesignTokens
//  - Full window coverage with centered messaging
//  - Zero business logic - pure presentation layer
//

import SwiftUI

struct DragDropZone: View {
    let isVisible: Bool
    let isDragHovering: Bool
    
    private let tokens = DesignTokens.shared
    
    var body: some View {
        if isVisible {
            ZStack {
                // Background overlay
                Rectangle()
                    .fill(Color.black.opacity(tokens.glassmorphic.transparency.dropZoneBackground))
                    .ignoresSafeArea()
                
                // Central drop area
                VStack(spacing: 24) {
                    // Drop icon
                    Image(systemName: isDragHovering ? "arrow.down.circle.fill" : "plus.circle")
                        .font(.system(size: 64, weight: .light))
                        .foregroundColor(.white.opacity(0.8))
                        .scaleEffect(isDragHovering ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isDragHovering)
                    
                    // Drop message
                    VStack(spacing: 8) {
                        Text(isDragHovering ? "Release to add files" : "Drop files here")
                            .font(.custom(tokens.typography.bodyFont, size: 18))
                            .fontWeight(.medium)
                            .foregroundColor(.white.opacity(0.9))
                        
                        Text("Images, PDFs, and text files supported")
                            .font(.custom(tokens.typography.bodyFont, size: 14))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                .padding(32)
                .background(
                    RoundedRectangle(cornerRadius: tokens.elements.inputBar.cornerRadius)
                        .fill(Color.black.opacity(tokens.glassmorphic.transparency.dropZoneCenter))
                        .overlay(
                            RoundedRectangle(cornerRadius: tokens.elements.inputBar.cornerRadius)
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            .white.opacity(isDragHovering ? 0.4 : 0.2),
                                            .white.opacity(isDragHovering ? 0.2 : 0.1)
                                        ],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    ),
                                    lineWidth: isDragHovering ? 2 : 1
                                )
                        )
                        .shadow(
                            color: .white.opacity(tokens.glassmorphic.shadows.innerGlow.opacity * (isDragHovering ? 1.5 : 1.0)),
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
                .scaleEffect(isDragHovering ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 0.2), value: isDragHovering)
            }
            .transition(.opacity.combined(with: .scale(scale: 0.95)))
            .animation(.easeInOut(duration: 0.3), value: isVisible)
        }
    }
}