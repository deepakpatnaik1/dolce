import SwiftUI
import MarkdownUI

struct MessageContentView: View {
    let content: String
    let accentColor: Color
    
    var body: some View {
        Markdown(content)
            .markdownTheme(.personaTheme(accentColor: accentColor))
    }
}

extension Theme {
    static func personaTheme(accentColor: Color) -> Theme {
        let tokens = DesignTokens.shared
        let codeBackgroundColor = Color(
            red: tokens.background.primary.red * 2,
            green: tokens.background.primary.green * 2,
            blue: tokens.background.primary.blue * 2
        )
        
        return Theme()
            // Base text style
            .text {
                FontFamily(.custom(tokens.typography.bodyFont))
                ForegroundColor(.white)
                FontSize(tokens.elements.scrollback.bodyFontSize)
            }
            // Text formatting
            .strong {
                FontWeight(.semibold)
                ForegroundColor(accentColor)
            }
            .emphasis {
                FontStyle(.italic)
                ForegroundColor(.white.opacity(0.95))
            }
            // Headings
            .heading1 { configuration in
                configuration.label
                    .markdownTextStyle {
                        ForegroundColor(accentColor)
                        FontSize(20)
                        FontWeight(.semibold)
                    }
                    .markdownMargin(top: .em(0.5), bottom: .em(0.25))
            }
            .heading2 { configuration in
                configuration.label
                    .markdownTextStyle {
                        ForegroundColor(accentColor)
                        FontSize(18)
                        FontWeight(.medium)
                    }
                    .markdownMargin(top: .em(0.4), bottom: .em(0.2))
            }
            .heading3 { configuration in
                configuration.label
                    .markdownTextStyle {
                        ForegroundColor(accentColor)
                        FontSize(16)
                        FontWeight(.medium)
                    }
                    .markdownMargin(top: .em(0.3), bottom: .em(0.15))
            }
            .heading4 { configuration in
                configuration.label
                    .markdownTextStyle {
                        ForegroundColor(accentColor)
                        FontSize(15)
                        FontWeight(.medium)
                    }
                    .markdownMargin(top: .em(0.2), bottom: .em(0.1))
            }
            .heading5 { configuration in
                configuration.label
                    .markdownTextStyle {
                        ForegroundColor(accentColor)
                        FontSize(14)
                        FontWeight(.medium)
                    }
                    .markdownMargin(top: .em(0.15), bottom: .em(0.1))
            }
            .heading6 { configuration in
                configuration.label
                    .markdownTextStyle {
                        ForegroundColor(accentColor)
                        FontSize(13)
                        FontWeight(.medium)
                    }
                    .markdownMargin(top: .em(0.15), bottom: .em(0.1))
            }
            // Code
            .code {
                FontFamily(.custom(tokens.typography.codeFont))
                FontSize(.em(0.85))
                ForegroundColor(accentColor.opacity(0.9))
                BackgroundColor(codeBackgroundColor.opacity(0.8))
            }
            .codeBlock { configuration in
                configuration.label
                    .relativeLineSpacing(.em(0.1))
                    .markdownTextStyle {
                        FontFamily(.custom(tokens.typography.codeFont))
                        FontSize(.em(0.85))
                        ForegroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .background(codeBackgroundColor.opacity(0.6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .markdownMargin(top: .em(0.3), bottom: .em(0.3))
            }
            // Lists
            .listItem { configuration in
                configuration.label
                    .markdownMargin(top: .em(0.15), bottom: .em(0.15))
            }
            .listMarker { configuration in
                if configuration.listType == .bulleted {
                    Text("•")
                        .foregroundColor(accentColor)
                        .font(.system(size: tokens.elements.scrollback.bodyFontSize))
                } else {
                    Text("\(configuration.itemNumber).")
                        .foregroundColor(accentColor)
                        .font(.system(size: tokens.elements.scrollback.bodyFontSize))
                }
            }
            // Blockquotes
            .blockquote { configuration in
                HStack(spacing: 0) {
                    Rectangle()
                        .fill(accentColor.opacity(0.5))
                        .frame(width: 3)
                    configuration.label
                        .markdownTextStyle {
                            FontStyle(.italic)
                            ForegroundColor(.white.opacity(0.85))
                        }
                        .padding(.leading, 12)
                }
                .markdownMargin(top: .em(0.3), bottom: .em(0.3))
            }
            // Links
            .link {
                ForegroundColor(accentColor)
                UnderlineStyle(.single)
            }
            // Horizontal rule
            .thematicBreak {
                Divider()
                    .overlay(accentColor.opacity(0.5))
                    .frame(height: 1)
                    .padding(.vertical, 8)
            }
            // Paragraph spacing
            .paragraph { configuration in
                configuration.label
                    .markdownMargin(top: .zero, bottom: .em(0.5))
            }
    }
}