//
//  ResponseParsingProtocol.swift
//  Dolce
//
//  Protocol definition for response parsing services
//
//  ATOMIC RESPONSIBILITY: Define contract for parsing LLM responses
//  - Parse raw response strings into structured TripleResponse
//  - Enable testing with mock parsers
//  - Support alternative parsing strategies
//  - Zero implementation, pure interface definition
//

import Foundation

/// Protocol for parsing LLM responses into structured format
protocol ResponseParsing {
    /// Parse a raw LLM response into a TripleResponse
    func parse(_ response: String) -> TripleResponse
}