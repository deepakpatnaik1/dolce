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
                    var buffer = Data()
                    let newline = UInt8(10) // ASCII newline character
                    
                    for try await byte in bytes {
                        buffer.append(byte)
                        
                        if byte == newline {
                            // Decode the complete line as UTF-8
                            if let line = String(data: buffer, encoding: .utf8) {
                                continuation.yield(line.trimmingCharacters(in: .whitespacesAndNewlines))
                            }
                            buffer = Data() // Reset buffer for next line
                        }
                    }
                    
                    // Handle any remaining data in buffer
                    if !buffer.isEmpty {
                        if let line = String(data: buffer, encoding: .utf8) {
                            continuation.yield(line.trimmingCharacters(in: .whitespacesAndNewlines))
                        }
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

enum HTTPExecutorError: Error, LocalizedError {
    case invalidResponse(String)
    case httpError(Int, String)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse(let message):
            return "Invalid HTTP Response: \(message)"
        case .httpError(let statusCode, let message):
            return "HTTP Error \(statusCode): \(message)"
        }
    }
}