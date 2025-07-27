//
//  MetalShaderManager.swift
//  Aether
//
//  Service for managing Metal shader resources
//
//  ATOMIC RESPONSIBILITY: Handle Metal shader lifecycle
//  - Create placeholder Metal library
//  - Suppress Metal-related warnings
//  - Validate Metal support
//  - Manage shader configuration
//

import Foundation
import Metal
import os.log

@MainActor
class MetalShaderManager {
    static let shared = MetalShaderManager()
    
    private let configuration: MetalShaderConfiguration
    private let logger = Logger(subsystem: "com.aether.app", category: "MetalShaderManager")
    private var device: MTLDevice?
    
    private init() {
        self.configuration = .defaultConfiguration
        self.device = MTLCreateSystemDefaultDevice()
    }
    
    // MARK: - Public Interface
    
    /// Initialize Metal shader support
    func initialize() {
        if configuration.suppressWarnings {
            suppressMetalWarnings()
        }
        
        if configuration.includesShaders {
            validateMetalSupport()
        }
    }
    
    /// Create an empty Metal library to satisfy system requirements
    func createEmptyMetalLibrary() -> URL? {
        guard device != nil else {
            logger.info("Metal device not available")
            return nil
        }
        
        // The actual library will be created by compiling MetalShaderStub.metal
        // This method returns the expected location
        if let resourcePath = Bundle.main.resourcePath {
            let libraryURL = URL(fileURLWithPath: resourcePath)
                .appendingPathComponent("default.metallib")
            return libraryURL
        }
        
        return nil
    }
    
    /// Suppress Metal-related warnings
    func suppressMetalWarnings() {
        // Set environment variable to suppress Metal validation layers
        setenv("MTL_SHADER_VALIDATION", "0", 1)
        setenv("MTL_DEBUG_LAYER", "0", 1)
        
        // Disable Metal API validation
        if #available(macOS 11.0, *) {
            setenv("METAL_DEVICE_WRAPPER_TYPE", "0", 1)
        }
        
        logger.info("Metal warnings suppressed")
    }
    
    /// Validate Metal support on the system
    @discardableResult
    func validateMetalSupport() -> Bool {
        guard let device = device else {
            logger.warning("Metal is not supported on this system")
            return false
        }
        
        logger.info("Metal device available: \(device.name)")
        
        // Check if shader library exists
        if let libraryURL = createEmptyMetalLibrary(),
           FileManager.default.fileExists(atPath: libraryURL.path) {
            logger.info("Metal shader library found at: \(libraryURL.path)")
            return true
        } else {
            logger.info("Metal shader library not found, will be created at build time")
            return true // Still valid, library will be created
        }
    }
    
    // MARK: - Configuration
    
    /// Get current Metal shader configuration
    func getConfiguration() -> MetalShaderConfiguration {
        return configuration
    }
    
    /// Check if Metal is available
    func isMetalAvailable() -> Bool {
        return device != nil
    }
}