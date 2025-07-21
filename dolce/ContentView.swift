//
//  ContentView.swift
//  dolce
//
//  Created by Deepak Patnaik on 21.07.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var messageStore = MessageStore()
    
    var body: some View {
        ZStack {
            // Background color using DesignTokens
            Color(
                red: DesignTokens.shared.background.primary.red,
                green: DesignTokens.shared.background.primary.green,
                blue: DesignTokens.shared.background.primary.blue
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Beautiful ScrollbackView with glassmorphic styling
                ScrollbackView(messages: messageStore.messages)
                
                // Simple input bar (temporary)
                HStack {
                    TextField("Ask anything...", text: .constant(""))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button("Send") {
                        // TODO: Connect to real input handling
                    }
                }
                .padding()
            }
        }
        .onAppear {
            messageStore.loadSampleMessages()
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 1000, height: 700)
}
