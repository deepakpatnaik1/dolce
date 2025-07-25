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
    let opacity: Opacity
    
    struct Typography: Codable {
        let bodyFont: String
        let codeFont: String
        let fontSize: FontSize
        
        struct FontSize: Codable {
            let xs: CGFloat
            let sm: CGFloat
            let md: CGFloat
            let base: CGFloat
            let lg: CGFloat
            let xl: CGFloat
            let xxl: CGFloat
            let xxxl: CGFloat
            let display: CGFloat
            let giant: CGFloat
        }
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
    
    struct Opacity: Codable {
        let text: OpacityText
        let background: OpacityBackground
        let border: OpacityBorder
        let shadow: OpacityShadow
        
        struct OpacityText: Codable {
            let primary: Double
            let secondary: Double
            let tertiary: Double
            let quaternary: Double
            let muted: Double
            let emphasis: Double
        }
        
        struct OpacityBackground: Codable {
            let strong: Double
            let medium: Double
            let subtle: Double
            let faint: Double
            let ghost: Double
        }
        
        struct OpacityBorder: Codable {
            let strong: Double
            let medium: Double
            let subtle: Double
            let faint: Double
        }
        
        struct OpacityShadow: Codable {
            let strong: Double
            let medium: Double
            let subtle: Double
        }
    }
    
    static let shared: DesignTokens = {
        let configPath = VaultPathProvider.configPath(for: "design-tokens.json")
        let url = URL(fileURLWithPath: configPath)
        
        guard let data = try? Data(contentsOf: url) else {
            // Return default tokens if file cannot be read
            return DesignTokens.createDefault()
        }
        
        do {
            let tokens = try JSONDecoder().decode(DesignTokens.self, from: data)
            return tokens
        } catch {
            // Return default tokens if decoding fails
            return DesignTokens.createDefault()
        }
    }()
    
    private static func createDefault() -> DesignTokens {
        // Return sensible defaults that allow the app to run
        return DesignTokens(
            typography: Typography(
                bodyFont: "iA Writer Quattro V",
                codeFont: "Menlo",
                fontSize: Typography.FontSize(
                    xs: 9,
                    sm: 10,
                    md: 11,
                    base: 12,
                    lg: 14,
                    xl: 15,
                    xxl: 16,
                    xxxl: 18,
                    display: 20,
                    giant: 64
                )
            ),
            layout: Layout(
                padding: ["containerPadding": 32],
                margins: [:],
                sizing: ["contentWidth": 592, "windowWidth": 1000, "windowHeight": 700],
                chrome: [
                    "titleBarHeight": 28,
                    "containerPadding": 16,
                    "controlsRowHeight": 40,
                    "textInternalPadding": 24
                ],
                fallbacks: [
                    "minTextHeight": 200,
                    "defaultWindowHeight": 400
                ]
            ),
            glassmorphic: Glassmorphic(
                transparency: Glassmorphic.Transparency(
                    inputBackground: 0.85,
                    borderTop: 0.3,
                    borderBottom: 0.1,
                    placeholder: 0.25,
                    controls: 0.7,
                    dropZoneBackground: 0.3,
                    dropZoneCenter: 0.6
                ),
                gradients: Glassmorphic.Gradients(
                    borderColors: ["white", "white"],
                    borderOpacities: [0.3, 0.1]
                ),
                shadows: Glassmorphic.Shadows(
                    innerGlow: Glassmorphic.Shadows.ShadowSpec(color: "white", opacity: 0.08, radius: 8, x: 0, y: -2),
                    outerShadow: Glassmorphic.Shadows.ShadowSpec(color: "black", opacity: 0.4, radius: 12, x: 0, y: 4),
                    greenGlow: Glassmorphic.Shadows.GreenGlow(radius1: 4, radius2: 8, opacity: 0.5)
                )
            ),
            elements: Elements(
                inputBar: Elements.InputBar(
                    cornerRadius: 12,
                    padding: 16,
                    textPadding: 20,
                    topPadding: 12,
                    bottomPadding: 12,
                    minHeight: 22,
                    placeholderText: "Ask anything...",
                    fontSize: 12,
                    placeholderPaddingHorizontal: 20,
                    controlsSpacing: 12,
                    defaultTextHeight: 22
                ),
                scrollback: Elements.Scrollback(
                    bodyFontSize: 12,
                    authorFontSize: 10,
                    fallbackColor: Elements.Scrollback.ColorData(red: 0.3, green: 0.5, blue: 0.8),
                    highlight: Elements.Scrollback.Highlight(
                        fillOpacity: 0.03,
                        borderOpacityMultiplier: 0.5,
                        shadowOpacityMultiplier: 0.3,
                        shadowRadiusMultiplier: 0.5,
                        borderWidth: 0.5,
                        shadowOffsetY: -1
                    ),
                    authorLabel: Elements.Scrollback.AuthorLabel(
                        minimalBadge: Elements.Scrollback.AuthorLabel.MinimalBadge(
                            backgroundColor: 0.15,
                            cornerRadius: 8,
                            accentColors: [
                                "boss": Elements.Scrollback.AuthorLabel.MinimalBadge.AccentColor(red: 0.4, green: 0.7, blue: 0.9),
                                "claude": Elements.Scrollback.AuthorLabel.MinimalBadge.AccentColor(red: 0.9, green: 0.7, blue: 0.5),
                                "samara": Elements.Scrollback.AuthorLabel.MinimalBadge.AccentColor(red: 0.5, green: 0.8, blue: 0.6),
                                "vanessa": Elements.Scrollback.AuthorLabel.MinimalBadge.AccentColor(red: 0.8, green: 0.6, blue: 0.4),
                                "vlad": Elements.Scrollback.AuthorLabel.MinimalBadge.AccentColor(red: 0.7, green: 0.5, blue: 0.8),
                                "lyra": Elements.Scrollback.AuthorLabel.MinimalBadge.AccentColor(red: 0.9, green: 0.6, blue: 0.9),
                                "eva": Elements.Scrollback.AuthorLabel.MinimalBadge.AccentColor(red: 0.6, green: 0.9, blue: 0.8),
                                "alicja": Elements.Scrollback.AuthorLabel.MinimalBadge.AccentColor(red: 0.8, green: 0.8, blue: 0.4),
                                "sonja": Elements.Scrollback.AuthorLabel.MinimalBadge.AccentColor(red: 0.9, green: 0.5, blue: 0.6),
                                "gunnar": Elements.Scrollback.AuthorLabel.MinimalBadge.AccentColor(red: 0.5, green: 0.6, blue: 0.9)
                            ]
                        ),
                        coloredBorder: Elements.Scrollback.AuthorLabel.ColoredBorder(
                            borderWidth: 2,
                            backgroundColor: 0.05,
                            cornerRadius: 4
                        ),
                        softColorFill: Elements.Scrollback.AuthorLabel.SoftColorFill(
                            cornerRadius: 6,
                            fillOpacity: 0.12
                        )
                    )
                ),
                buttons: Elements.Buttons(
                    plusSize: 24,
                    sendSize: 20,
                    indicatorSize: 8
                ),
                panes: Elements.Panes(
                    spacing: 8,
                    compactSpacing: 4,
                    borderRadius: 8,
                    borderOpacity: 0.2,
                    borderWidth: 1,
                    topPadding: 20,
                    textOpacity: 0.8
                ),
                separators: Elements.Separators(
                    width: 1,
                    glowRadius: 2,
                    topPadding: 16,
                    bottomPadding: 16
                )
            ),
            animations: Animations(
                paneTransition: Animations.PaneTransition(
                    response: 0.2,
                    dampingFraction: 0.8,
                    blendDuration: 0
                ),
                window: Animations.Window(animationDuration: 0.25),
                messageNavigation: Animations.MessageNavigation(
                    scrollDuration: 0.3,
                    smoothScrollIncrement: 40,
                    smoothScrollDuration: 0.25
                ),
                textExpansion: Animations.TextExpansion(
                    response: 0.1,
                    dampingFraction: 0.8,
                    blendDuration: 0,
                    animationThreshold: 2
                )
            ),
            pane: Pane(
                widthFraction: 0.3333333333333333,
                fallbackWidth: 400,
                windowSizes: Pane.WindowSizes(
                    oneThird: 0.3333333333333333,
                    twoThirds: 0.6666666666666666,
                    full: 1.0
                )
            ),
            background: Background(
                primary: Background.Primary(red: 0.04, green: 0.04, blue: 0.05)
            ),
            opacity: Opacity(
                text: Opacity.OpacityText(
                    primary: 1.0,
                    secondary: 0.9,
                    tertiary: 0.85,
                    quaternary: 0.8,
                    muted: 0.6,
                    emphasis: 0.95
                ),
                background: Opacity.OpacityBackground(
                    strong: 0.9,
                    medium: 0.6,
                    subtle: 0.3,
                    faint: 0.1,
                    ghost: 0.05
                ),
                border: Opacity.OpacityBorder(
                    strong: 0.5,
                    medium: 0.3,
                    subtle: 0.2,
                    faint: 0.1
                ),
                shadow: Opacity.OpacityShadow(
                    strong: 0.4,
                    medium: 0.3,
                    subtle: 0.2
                )
            )
        )
    }
}