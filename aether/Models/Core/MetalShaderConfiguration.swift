//
//  MetalShaderConfiguration.swift
//  Aether
//
//  Configuration for Metal shader handling
//
//  ATOMIC RESPONSIBILITY: Data structure for Metal shader settings
//  - Tracks whether shaders are included
//  - Specifies shader library name
//  - Controls warning suppression
//  - Zero logic - pure data container
//

import Foundation

struct MetalShaderConfiguration {
    let includesShaders: Bool
    let shaderLibraryName: String?
    let suppressWarnings: Bool
    
    // MARK: - Factory Methods
    
    /// Default configuration with stub shader
    static var defaultConfiguration: MetalShaderConfiguration {
        return MetalShaderConfiguration(
            includesShaders: true,
            shaderLibraryName: "default",
            suppressWarnings: true
        )
    }
    
    /// Configuration for no shaders
    static var noShadersConfiguration: MetalShaderConfiguration {
        return MetalShaderConfiguration(
            includesShaders: false,
            shaderLibraryName: nil,
            suppressWarnings: true
        )
    }
}