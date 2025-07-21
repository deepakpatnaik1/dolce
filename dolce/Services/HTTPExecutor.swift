//
//  HTTPExecutor.swift
//  Dolce
//
//  Atomic HTTP executor
//
//  ATOMIC RESPONSIBILITY: Execute HTTP requests only
//  - Send URLRequest and get response
//  - Handle streaming and non-streaming
//  - Basic HTTP error checking
//  - Zero request building, zero body building, zero parsing
//

import Foundation

struct HTTPExecutor {
    
    /// Execute HTTP request and return raw response data
    static func executeRequest(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPExecutorError.invalidResponse("Response is not HTTP")
        }
        
        // Check for HTTP errors
        guard 200...299 ~= httpResponse.statusCode else {
            throw HTTPExecutorError.httpError(httpResponse.statusCode, "HTTP \(httpResponse.statusCode)")
        }
        
        return (data, httpResponse)
    }
    
    /// Execute streaming HTTP request and return String stream
    static func executeStreamingRequest(_ request: URLRequest) async throws -> AsyncThrowingStream<String, Error> {
        
        let (bytes, response) = try await URLSession.shared.bytes(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw HTTPExecutorError.invalidResponse("Response is not HTTP")
        }
        
        // Check for HTTP errors
        guard 200...299 ~= httpResponse.statusCode else {
            throw HTTPExecutorError.httpError(httpResponse.statusCode, "HTTP \(httpResponse.statusCode)")
        }
        
        return AsyncThrowingStream { continuation in
            Task {
                do {
                    var lineBuffer = ""
                    for try await byte in bytes {
                        let char = String(UnicodeScalar(byte))
                        lineBuffer += char
                        
                        if char == "\n" {
                            continuation.yield(lineBuffer.trimmingCharacters(in: .whitespacesAndNewlines))
                            lineBuffer = ""
                        }
                    }
                    
                    if !lineBuffer.isEmpty {
                        continuation.yield(lineBuffer.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    
                    continuation.finish()
                } catch {
                    continuation.finish(throwing: error)
                }
            }
        }
    }
}

// MARK: - Error Types

enum HTTPExecutorError: Error {
    case invalidResponse(String)
    case httpError(Int, String)
}