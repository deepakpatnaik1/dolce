//
//  TextHeightConstraints.swift
//  Dolce
//
//  Model for text height constraints and state
//
//  ATOMIC RESPONSIBILITY: Height constraint data structure
//  - Define minimum and maximum height bounds
//  - Track current height state
//  - Provide constraint checking properties
//  - Zero logic - pure data container
//

import Foundation

struct TextHeightConstraints {
    let minimum: CGFloat
    let maximum: CGFloat
    let current: CGFloat
    
    var isAtMaximum: Bool {
        current >= maximum
    }
    
    var isAtMinimum: Bool {
        current <= minimum
    }
    
    var constrainedHeight: CGFloat {
        min(maximum, max(minimum, current))
    }
    
    var availableGrowth: CGFloat {
        max(0, maximum - current)
    }
}