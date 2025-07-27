import SwiftUI

struct MessageContentView: View {
    let content: String
    let accentColor: Color
    
    private let parser = MarkdownParser()
    private let renderer = SwiftUIMarkdownRenderer()
    
    var body: some View {
        // New swift-markdown implementation
        let document = parser.parse(content)
        renderer.render(document, accentColor: accentColor)
    }
}