//
//  SwiftUIMarkdownRenderer.swift
//  dolce
//
//  Atomic LEGO: Convert Markdown AST to SwiftUI views
//

import SwiftUI
import Markdown

/// Renders Markdown AST nodes as SwiftUI views
class SwiftUIMarkdownRenderer {
    private let tokens = DesignTokens.shared
    
    /// Render a markdown document to SwiftUI
    func render(_ document: Document, accentColor: Color) -> AnyView {
        return AnyView(
            VStack(alignment: .leading, spacing: 0) {
                ForEach(Array(document.children.enumerated()), id: \.offset) { _, node in
                    self.renderNode(node, accentColor: accentColor)
                }
            }
        )
    }
    
    // MARK: - Node Rendering
    
    private func renderNode(_ node: any Markup, accentColor: Color) -> AnyView {
        switch node {
        case let paragraph as Paragraph:
            return renderParagraph(paragraph, accentColor: accentColor)
        case let heading as Heading:
            return renderHeading(heading, accentColor: accentColor)
        case let list as UnorderedList:
            return renderUnorderedList(list, accentColor: accentColor)
        case let list as OrderedList:
            return renderOrderedList(list, accentColor: accentColor)
        case let codeBlock as CodeBlock:
            return renderCodeBlock(codeBlock, accentColor: accentColor)
        case let blockQuote as BlockQuote:
            return renderBlockQuote(blockQuote, accentColor: accentColor)
        case let thematicBreak as ThematicBreak:
            return renderThematicBreak(thematicBreak, accentColor: accentColor)
        default:
            return renderInlineContent(node, accentColor: accentColor)
        }
    }
    
    // MARK: - Block Elements
    
    private func renderParagraph(_ paragraph: Paragraph, accentColor: Color) -> AnyView {
        AnyView(
            renderInlineContent(paragraph, accentColor: accentColor)
                .padding(.bottom, tokens.elements.scrollback.bodyFontSize * 0.5)
        )
    }
    
    private func renderHeading(_ heading: Heading, accentColor: Color) -> AnyView {
        let level = heading.level
        let fontSize: CGFloat = {
            switch level {
            case 1: return 20
            case 2: return 18
            case 3: return 16
            case 4: return 15
            case 5: return 14
            case 6: return 13
            default: return 16
            }
        }()
        
        let topPadding: CGFloat = {
            switch level {
            case 1: return 10
            case 2: return 8
            case 3: return 6
            default: return 4
            }
        }()
        
        let bottomPadding: CGFloat = {
            switch level {
            case 1: return 5
            case 2: return 4
            case 3: return 3
            default: return 2
            }
        }()
        
        return AnyView(
            renderInlineContent(heading, accentColor: accentColor)
                .font(.custom(tokens.typography.bodyFont, size: fontSize))
                .fontWeight(level <= 2 ? .semibold : .medium)
                .foregroundColor(accentColor)
                .padding(.top, topPadding)
                .padding(.bottom, bottomPadding)
        )
    }
    
    private func renderUnorderedList(_ list: UnorderedList, accentColor: Color) -> AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: 3) {
                ForEach(Array(list.listItems.enumerated()), id: \.offset) { _, item in
                    self.renderListItem(item, isOrdered: false, number: 0, accentColor: accentColor)
                }
            }
        )
    }
    
    private func renderOrderedList(_ list: OrderedList, accentColor: Color) -> AnyView {
        AnyView(
            VStack(alignment: .leading, spacing: 3) {
                ForEach(Array(list.listItems.enumerated()), id: \.offset) { index, item in
                    self.renderListItem(item, isOrdered: true, number: index + 1, accentColor: accentColor)
                }
            }
        )
    }
    
    private func renderListItem(_ item: ListItem, isOrdered: Bool, number: Int, accentColor: Color) -> AnyView {
        AnyView(
            HStack(alignment: .top, spacing: 8) {
                // Colored bullet or number
                SwiftUI.Text(isOrdered ? "\(number)." : "•")
                    .font(.custom(tokens.typography.bodyFont, size: tokens.elements.scrollback.bodyFontSize))
                    .foregroundColor(accentColor)
                    .frame(minWidth: 15, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(item.children.enumerated()), id: \.offset) { _, child in
                        self.renderNode(child, accentColor: accentColor)
                    }
                }
            }
        )
    }
    
    private func renderCodeBlock(_ codeBlock: CodeBlock, accentColor: Color) -> AnyView {
        let codeBackgroundColor = Color(
            red: tokens.background.primary.red * 2,
            green: tokens.background.primary.green * 2,
            blue: tokens.background.primary.blue * 2
        )
        
        return AnyView(
            SwiftUI.Text(codeBlock.code)
                .font(.custom(tokens.typography.codeFont, size: tokens.elements.scrollback.bodyFontSize * 0.85))
                .foregroundColor(.white.opacity(0.9))
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(codeBackgroundColor.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.vertical, 6)
        )
    }
    
    private func renderBlockQuote(_ blockQuote: BlockQuote, accentColor: Color) -> AnyView {
        AnyView(
            HStack(spacing: 0) {
                Rectangle()
                    .fill(accentColor.opacity(0.5))
                    .frame(width: 3)
                
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(Array(blockQuote.children.enumerated()), id: \.offset) { _, child in
                        self.renderNode(child, accentColor: accentColor)
                    }
                }
                .italic()
                .foregroundColor(.white.opacity(0.85))
                .padding(.leading, 12)
            }
            .padding(.vertical, 6)
        )
    }
    
    private func renderThematicBreak(_ thematicBreak: ThematicBreak, accentColor: Color) -> AnyView {
        AnyView(
            Divider()
                .overlay(accentColor.opacity(0.5))
                .frame(height: 1)
                .padding(.vertical, 8)
        )
    }
    
    // MARK: - Inline Content
    
    private func renderInlineContent(_ node: any Markup, accentColor: Color) -> AnyView {
        let inlineElements = collectInlineElements(from: node)
        
        return AnyView(
            inlineElements.reduce(SwiftUI.Text("")) { result, element in
                result + renderInlineElement(element, accentColor: accentColor)
            }
            .font(.custom(tokens.typography.bodyFont, size: tokens.elements.scrollback.bodyFontSize))
            .foregroundColor(.white)
        )
    }
    
    private func collectInlineElements(from node: any Markup) -> [any Markup] {
        var elements: [any Markup] = []
        
        if node is InlineMarkup {
            elements.append(node)
        } else {
            for child in node.children {
                elements.append(contentsOf: collectInlineElements(from: child))
            }
        }
        
        return elements
    }
    
    private func renderInlineElement(_ element: any Markup, accentColor: Color) -> SwiftUI.Text {
        switch element {
        case let text as Markdown.Text:
            return SwiftUI.Text(text.string)
        
        case let strong as Strong:
            let innerText = strong.children.map { child in
                renderInlineElement(child, accentColor: accentColor)
            }.reduce(SwiftUI.Text(""), +)
            return innerText
                .fontWeight(.semibold)
                .foregroundColor(accentColor)
        
        case let emphasis as Emphasis:
            let innerText = emphasis.children.map { child in
                renderInlineElement(child, accentColor: accentColor)
            }.reduce(SwiftUI.Text(""), +)
            return innerText
                .italic()
                .foregroundColor(.white.opacity(0.95))
        
        case let code as InlineCode:
            return SwiftUI.Text(code.code)
                .font(.custom(tokens.typography.codeFont, size: tokens.elements.scrollback.bodyFontSize * 0.85))
                .foregroundColor(accentColor.opacity(0.9))
        
        case let link as Markdown.Link:
            let innerText = link.children.map { child in
                renderInlineElement(child, accentColor: accentColor)
            }.reduce(SwiftUI.Text(""), +)
            return innerText
                .foregroundColor(accentColor)
                .underline()
        
        case _ as SoftBreak:
            return SwiftUI.Text(" ")
        
        case _ as LineBreak:
            return SwiftUI.Text("\n")
        
        default:
            // For any other inline elements, try to extract text
            if let textElement = element as? Markdown.Text {
                return SwiftUI.Text(textElement.string)
            }
            return SwiftUI.Text("")
        }
    }
}