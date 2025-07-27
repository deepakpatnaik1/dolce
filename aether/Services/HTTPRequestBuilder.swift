//
//  HTTPRequestBuilder.swift
//  Aether
//
//  Atomic HTTP request builder
//
//  ATOMIC RESPONSIBILITY: Build HTTP requests only
//  - Construct URLRequest from components
//  - Add headers and authentication
//  - Validate inputs
//  - Zero execution, zero body building, zero parsing
//

import Foundation

struct HTTPRequestBuilder {
    
    /// Build HTTP request for API calls
    static func buildRequest(
        baseURL: String,
        endpoint: String? = nil,
        apiKey: String,
        requestBody: [String: Any],
        headers: [String: String] = [:]
    ) throws -> URLRequest {
        
        // Validate inputs
        try validateInputs(baseURL: baseURL, apiKey: apiKey, requestBody: requestBody)
        
        // Build URL - use provided endpoint (required for proper routing)
        let finalEndpoint = endpoint ?? "/messages"
        let url = try buildURL(baseURL: baseURL, endpoint: finalEndpoint)
        
        // Create request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Set standard headers  
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Set body
        let jsonData = try JSONSerialization.data(withJSONObject: requestBody)
        request.httpBody = jsonData
        
        return request
    }
    
    // MARK: - Private Helpers
    
    private static func buildURL(baseURL: String, endpoint: String) throws -> URL {
        let fullURL = baseURL.hasSuffix("/") ? baseURL + endpoint.dropFirst() : baseURL + endpoint
        
        guard let url = URL(string: fullURL) else {
            throw HTTPRequestBuilderError.invalidURL("Cannot create URL from: \(fullURL)")
        }
        
        return url
    }
    
    private static func validateInputs(baseURL: String, apiKey: String, requestBody: [String: Any]) throws {
        guard !baseURL.isEmpty else {
            throw HTTPRequestBuilderError.invalidInput("Base URL cannot be empty")
        }
        
        guard !apiKey.isEmpty else {
            throw HTTPRequestBuilderError.invalidInput("API key cannot be empty")
        }
        
        guard !requestBody.isEmpty else {
            throw HTTPRequestBuilderError.invalidInput("Request body cannot be empty")
        }
    }
    
}

// MARK: - Error Types

enum HTTPRequestBuilderError: Error {
    case invalidURL(String)
    case invalidInput(String)
}