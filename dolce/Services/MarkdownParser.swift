//
//  MarkdownParser.swift
//  dolce
//
//  Atomic LEGO: Parse markdown strings into AST
//

import Foundation
import Markdown

/// Parses markdown content into an Abstract Syntax Tree
class MarkdownParser {
    
    /// Parse markdown string into a Document AST
    func parse(_ content: String) -> Document {
        return Document(parsing: content)
    }
}