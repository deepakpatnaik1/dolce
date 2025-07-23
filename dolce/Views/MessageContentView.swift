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
        Theme()
            .heading1 { configuration in
                configuration.label
                    .foregroundColor(accentColor)
                    .font(.system(size: 20, weight: .semibold))
            }
            .heading2 { configuration in
                configuration.label
                    .foregroundColor(accentColor)
                    .font(.system(size: 18, weight: .medium))
            }
            .heading3 { configuration in
                configuration.label
                    .foregroundColor(accentColor)
                    .font(.system(size: 16, weight: .medium))
            }
            .heading4 { configuration in
                configuration.label
                    .foregroundColor(accentColor)
                    .font(.system(size: 15, weight: .medium))
            }
            .heading5 { configuration in
                configuration.label
                    .foregroundColor(accentColor)
                    .font(.system(size: 14, weight: .medium))
            }
            .heading6 { configuration in
                configuration.label
                    .foregroundColor(accentColor)
                    .font(.system(size: 13, weight: .medium))
            }
            .thematicBreak {
                Divider()
                    .overlay(accentColor.opacity(0.5))
                    .padding(.vertical, 8)
            }
    }
}