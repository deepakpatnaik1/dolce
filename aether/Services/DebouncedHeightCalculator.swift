//
//  DebouncedHeightCalculator.swift
//  Aether
//
//  Debounced text height calculation service
//
//  ATOMIC RESPONSIBILITY: Debounce height calculation requests
//  - Buffer rapid calculation requests
//  - Cancel pending calculations when new requests arrive
//  - Forward to TextMeasurementEngine after delay
//  - Prevent calculation pile-up during rapid changes
//

import Foundation
import Combine
import AppKit

@MainActor
class DebouncedHeightCalculator: ObservableObject {
    private var pendingRequest: HeightCalculationRequest?
    private var debounceTask: Task<Void, Never>?
    private let debounceInterval: TimeInterval
    
    init(debounceInterval: TimeInterval = 0.1) {
        self.debounceInterval = debounceInterval
    }
    
    /// Calculate height with debouncing to prevent rapid recalculations
    func calculateHeight(
        for text: String,
        font: NSFont,
        availableWidth: CGFloat,
        completion: @escaping (CGFloat) -> Void
    ) {
        // Cancel any pending calculation
        debounceTask?.cancel()
        
        // Create new request
        let request = HeightCalculationRequest(
            text: text,
            font: font,
            availableWidth: availableWidth
        )
        pendingRequest = request
        
        // Schedule debounced calculation using Task
        debounceTask = Task { [weak self] in
            // Check if self is still available
            guard let self = self else { return }
            
            // Wait for debounce interval
            do {
                try await Task.sleep(nanoseconds: UInt64(self.debounceInterval * 1_000_000_000))
            } catch {
                // Task was cancelled
                return
            }
            
            // Check if this is still the current request
            guard let currentRequest = self.pendingRequest,
                  currentRequest.id == request.id else { return }
            
            // Perform actual calculation
            let height = TextMeasurementEngine.calculateHeight(
                for: currentRequest.text,
                font: currentRequest.font,
                availableWidth: currentRequest.availableWidth
            )
            
            // Clear pending request
            self.pendingRequest = nil
            
            // Return result (already on MainActor)
            completion(height)
        }
    }
    
    /// Cancel any pending calculations
    func cancelPendingCalculations() {
        debounceTask?.cancel()
        debounceTask = nil
        pendingRequest = nil
    }
}