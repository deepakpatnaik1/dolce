//
//  ModelPickerView.swift
//  Dolce
//
//  Atomic model picker dropdown
//
//  ATOMIC RESPONSIBILITY: Model selection UI only
//  - Display current selected model
//  - Show dropdown with available models
//  - Handle model selection interaction
//  - Zero API logic, zero state persistence
//

import SwiftUI

struct ModelPickerView: View {
    @State private var showDropdown = false
    @ObservedObject private var runtimeModelManager = RuntimeModelManager.shared
    
    private var availableModels: [LLMModel] {
        // Refresh available models to include newly detected local models
        return ModelProvider.getAvailableModels()
    }
    
    private var selectedModel: LLMModel? {
        availableModels.first { $0.key == runtimeModelManager.selectedModel }
    }
    
    var body: some View {
        ZStack {
            if showDropdown {
                dropdownView
            } else {
                buttonView
            }
        }
        .onTapGesture {
            if !showDropdown {
                // Don't refresh to avoid network crashes
                showDropdown.toggle()
            }
        }
        .onKeyPress(.escape) {
            showDropdown = false
            return .handled
        }
    }
    
    // MARK: - Button View
    
    private var buttonView: some View {
        HStack(spacing: 4) {
            Text(selectedModel?.displayName ?? "no-model")
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
            
            Image(systemName: "chevron.down")
                .font(.system(size: 7, weight: .medium))
                .foregroundColor(Color.white.opacity(0.6))
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.white.opacity(0.1))
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
        )
    }
    
    // MARK: - Dropdown View
    
    private var dropdownView: some View {
        VStack(spacing: 1) {
            ForEach(availableModels, id: \.key) { model in
                modelItemView(model)
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.black.opacity(0.9))
                .stroke(Color.white.opacity(0.2), lineWidth: 0.5)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
        )
        .onTapGesture {
            // Prevent dropdown from closing when tapping inside
        }
        .background(
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    showDropdown = false
                }
        )
    }
    
    private func modelItemView(_ model: LLMModel) -> some View {
        HStack(spacing: 6) {
            Text(model.displayName)
                .font(.system(size: 9, weight: .medium))
                .foregroundColor(Color.white.opacity(0.8))
            
            Spacer()
            
            if model.key == selectedModel?.key {
                Image(systemName: "checkmark")
                    .font(.system(size: 7, weight: .medium))
                    .foregroundColor(Color.white.opacity(0.6))
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(
                    model.key == selectedModel?.key ? 0.15 : 0.05
                ))
        )
        .onTapGesture {
            selectModel(model)
        }
    }
    
    // MARK: - Actions
    
    private func selectModel(_ model: LLMModel) {
        runtimeModelManager.selectModel(model.key)
        showDropdown = false
    }
}

#Preview {
    return ModelPickerView()
        .padding()
        .background(Color.black)
}