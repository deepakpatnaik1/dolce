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
        VStack(spacing: 0) {
            // Message list (temporary simple version)
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    ForEach(messageStore.messages) { message in
                        VStack(alignment: .leading, spacing: 4) {
                            Text(message.displayAuthor)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(message.content)
                                .font(.body)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    }
                }
            }
            
            // Simple input bar (temporary)
            HStack {
                TextField("Type a message...", text: .constant(""))
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send") {
                    // TODO: Connect to real input handling
                }
            }
            .padding()
        }
        .onAppear {
            messageStore.loadSampleMessages()
        }
    }
}

#Preview {
    ContentView()
}
