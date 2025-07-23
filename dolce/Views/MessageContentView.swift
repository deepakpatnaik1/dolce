import SwiftUI
import MarkdownUI

struct MessageContentView: View {
    let content: String
    
    var body: some View {
        Markdown(content)
    }
}