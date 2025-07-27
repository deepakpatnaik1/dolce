//
//  aetherApp.swift
//  aether
//
//  Created by Deepak Patnaik on 21.07.25.
//

import SwiftUI

@main
struct aetherApp: App {
    init() {
        // Initialize Metal shader manager to suppress warnings
        MetalShaderManager.shared.initialize()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}