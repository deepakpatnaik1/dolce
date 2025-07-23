//
//  ContentView.swift
//  dolce
//
//  Created by Deepak Patnaik on 21.07.25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var messageStore = MessageStore()
    @StateObject private var conversationOrchestrator: ConversationOrchestrator
    @StateObject private var fileDropHandler = FileDropHandler()
    @StateObject private var inputBarCoordinator: InputBarCoordinator
    
    init() {
        let messageStore = MessageStore()
        let conversationOrchestrator = ConversationOrchestrator(messageStore: messageStore)
        let fileDropHandler = FileDropHandler()
        
        self._messageStore = StateObject(wrappedValue: messageStore)
        self._conversationOrchestrator = StateObject(wrappedValue: conversationOrchestrator)
        self._fileDropHandler = StateObject(wrappedValue: fileDropHandler)
        self._inputBarCoordinator = StateObject(wrappedValue: InputBarCoordinator(
            conversationOrchestrator: conversationOrchestrator,
            fileDropHandler: fileDropHandler,
            messageStore: messageStore
        ))
    }
    
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
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // Beautiful InputBarView with glassmorphic styling
                InputBarView(
                    fileDropHandler: fileDropHandler,
                    coordinator: inputBarCoordinator
                )
            }
            
            // Full-window drag-drop overlay
            DragDropZone(
                isVisible: fileDropHandler.isHovering,
                isDragHovering: fileDropHandler.isHovering
            )
        }
        .onAppear {
            // App initialization
        }
        .onDrop(of: [.fileURL, .image, .pdf, .plainText], isTargeted: $fileDropHandler.isHovering) { providers in
            fileDropHandler.handleDrop(providers: providers)
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 1000, height: 700)
}
