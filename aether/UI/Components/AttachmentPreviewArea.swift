//
//  AttachmentPreviewArea.swift
//  Aether
//
//  Pure UI component for file attachment previews
//
//  ATOMIC RESPONSIBILITY: Attachment preview presentation only
//  - Display file thumbnails and metadata in InputBar context
//  - Glassmorphic styling with DesignTokens integration
//  - Remove/manage attachment interactions
//  - Zero business logic - pure presentation layer
//

import SwiftUI

struct AttachmentPreviewArea: View {
    let attachments: [DroppedFile]
    let onRemove: (UUID) -> Void
    
    private let tokens = DesignTokens.shared
    
    var body: some View {
        if !attachments.isEmpty {
            VStack(spacing: 8) {
                // Header
                HStack {
                    Text("\(attachments.count) file\(attachments.count == 1 ? "" : "s") attached")
                        .font(.custom(tokens.typography.bodyFont, size: 11))
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    // Clear all button
                    Button("Clear all") {
                        for attachment in attachments {
                            onRemove(attachment.id)
                        }
                    }
                    .font(.custom(tokens.typography.bodyFont, size: 11))
                    .foregroundColor(.white.opacity(0.7))
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, tokens.elements.inputBar.textPadding)
                .padding(.bottom, 4)
                
                // File previews
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(attachments) { attachment in
                            AttachmentPreviewItem(
                                attachment: attachment,
                                onRemove: { onRemove(attachment.id) }
                            )
                        }
                    }
                    .padding(.horizontal, tokens.elements.inputBar.textPadding)
                }
            }
            .padding(.top, 8)
            .background(
                Rectangle()
                    .fill(Color.black.opacity(0.1))
                    .overlay(
                        Rectangle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        .white.opacity(0.05),
                                        .white.opacity(0.02)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                ),
                                lineWidth: 1
                            ),
                        alignment: .top
                    )
            )
        }
    }
}

struct AttachmentPreviewItem: View {
    let attachment: DroppedFile
    let onRemove: () -> Void
    
    private let tokens = DesignTokens.shared
    
    var body: some View {
        VStack(spacing: 4) {
            // File icon/thumbnail
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.black.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .frame(width: 48, height: 48)
                
                // Icon or image
                if attachment.isImage, let nsImage = NSImage(data: attachment.data) {
                    // Image thumbnail
                    Image(nsImage: nsImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 44, height: 44)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    // File type icon
                    Image(systemName: attachment.type.iconName)
                        .font(.system(size: 20, weight: .light))
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Remove button
                Button {
                    onRemove()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.black.opacity(0.8))
                        .background(
                            Circle()
                                .fill(.white)
                                .frame(width: 16, height: 16)
                        )
                }
                .buttonStyle(PlainButtonStyle())
                .offset(x: 18, y: -18)
            }
            
            // File info
            VStack(spacing: 2) {
                // File name (truncated)
                Text(attachment.name)
                    .font(.custom(tokens.typography.bodyFont, size: 10))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
                    .truncationMode(.middle)
                    .frame(maxWidth: 64)
                
                // File size
                Text(attachment.formattedSize)
                    .font(.custom(tokens.typography.bodyFont, size: 9))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.2))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.05), lineWidth: 1)
                )
        )
        .frame(width: 72)
    }
}