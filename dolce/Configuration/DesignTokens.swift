//
//  DesignTokens.swift
//  Dolce
//
//  Design system constants loader
//
//  ATOMIC RESPONSIBILITY: Load and provide design constants from DesignTokens.json
//  - Pure data structures with zero business logic
//  - Single source of truth for all styling constants
//  - Clean typed access to typography, colors, spacing, animations
//

import Foundation

struct DesignTokens: Codable {
    let typography: Typography
    let layout: Layout
    let glassmorphic: Glassmorphic
    let elements: Elements
    let animations: Animations
    let pane: Pane
    let background: Background
    
    struct Typography: Codable {
        let bodyFont: String
        let codeFont: String
    }
    
    struct Layout: Codable {
        let padding: [String: Double]
        let margins: [String: Double]
        let sizing: [String: Double]
        let chrome: [String: Double]
        let fallbacks: [String: Double]
    }
    
    struct Glassmorphic: Codable {
        let transparency: Transparency
        let gradients: Gradients
        let shadows: Shadows
        
        struct Transparency: Codable {
            let inputBackground: Double
            let borderTop: Double
            let borderBottom: Double
            let placeholder: Double
            let controls: Double
            let dropZoneBackground: Double
            let dropZoneCenter: Double
        }
        
        struct Gradients: Codable {
            let borderColors: [String]
            let borderOpacities: [Double]
        }
        
        struct Shadows: Codable {
            let innerGlow: ShadowSpec
            let outerShadow: ShadowSpec
            let greenGlow: GreenGlow
            
            struct ShadowSpec: Codable {
                let color: String
                let opacity: Double
                let radius: Double
                let x: Double
                let y: Double
            }
            
            struct GreenGlow: Codable {
                let radius1: Double
                let radius2: Double
                let opacity: Double
            }
        }
    }
    
    struct Elements: Codable {
        let inputBar: InputBar
        let scrollback: Scrollback
        let buttons: Buttons
        let panes: Panes
        let separators: Separators
        
        struct InputBar: Codable {
            let cornerRadius: Double
            let padding: Double
            let textPadding: Double
            let topPadding: Double
            let bottomPadding: Double
            let minHeight: Double
            let placeholderText: String
            let fontSize: Double
            let placeholderPaddingHorizontal: Double
            let controlsSpacing: Double
            let defaultTextHeight: Double
        }
        
        struct Scrollback: Codable {
            let bodyFontSize: Double
            let authorFontSize: Double
            let fallbackColor: ColorData
            let highlight: Highlight
            let authorLabel: AuthorLabel
            
            struct ColorData: Codable {
                let red: Double
                let green: Double
                let blue: Double
            }
            
            struct Highlight: Codable {
                let fillOpacity: Double
                let borderOpacityMultiplier: Double
                let shadowOpacityMultiplier: Double
                let shadowRadiusMultiplier: Double
                let borderWidth: Double
                let shadowOffsetY: Double
            }
            
            struct AuthorLabel: Codable {
                let minimalBadge: MinimalBadge
                let coloredBorder: ColoredBorder
                let softColorFill: SoftColorFill
                
                struct MinimalBadge: Codable {
                    let backgroundColor: Double
                    let cornerRadius: Double
                    let accentColors: [String: AccentColor]
                    
                    struct AccentColor: Codable {
                        let red: Double
                        let green: Double
                        let blue: Double
                    }
                }
                
                struct ColoredBorder: Codable {
                    let borderWidth: Double
                    let backgroundColor: Double
                    let cornerRadius: Double
                }
                
                struct SoftColorFill: Codable {
                    let cornerRadius: Double
                    let fillOpacity: Double
                }
            }
        }
        
        struct Buttons: Codable {
            let plusSize: Double
            let sendSize: Double
            let indicatorSize: Double
        }
        
        struct Panes: Codable {
            let spacing: Double
            let compactSpacing: Double
            let borderRadius: Double
            let borderOpacity: Double
            let borderWidth: Double
            let topPadding: Double
            let textOpacity: Double
        }
        
        struct Separators: Codable {
            let width: Double
            let glowRadius: Double
            let topPadding: Double
            let bottomPadding: Double
        }
    }
    
    struct Animations: Codable {
        let paneTransition: PaneTransition
        let window: Window
        let messageNavigation: MessageNavigation
        let textExpansion: TextExpansion
        
        struct PaneTransition: Codable {
            let response: Double
            let dampingFraction: Double
            let blendDuration: Double
        }
        
        struct Window: Codable {
            let animationDuration: Double
        }
        
        struct MessageNavigation: Codable {
            let scrollDuration: Double
            let smoothScrollIncrement: Double
            let smoothScrollDuration: Double
        }
        
        struct TextExpansion: Codable {
            let response: Double
            let dampingFraction: Double
            let blendDuration: Double
            let animationThreshold: Double
        }
    }
    
    struct Pane: Codable {
        let widthFraction: Double
        let fallbackWidth: Double
        let windowSizes: WindowSizes
        
        struct WindowSizes: Codable {
            let oneThird: Double
            let twoThirds: Double
            let full: Double
        }
    }
    
    struct Background: Codable {
        let primary: Primary
        
        struct Primary: Codable {
            let red: Double
            let green: Double
            let blue: Double
        }
    }
    
    static let shared: DesignTokens = {
        let configPath = "/Users/d.patnaik/code/dolce/dolceVault/config/design-tokens.json"
        let url = URL(fileURLWithPath: configPath)
        
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not read design-tokens.json from vault")
        }
        
        do {
            let tokens = try JSONDecoder().decode(DesignTokens.self, from: data)
            return tokens
        } catch {
            fatalError("Could not decode design-tokens.json: \(error)")
        }
    }()
}