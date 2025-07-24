import Foundation

struct OmniscientBundle {
    let instructions: String
    let bossContext: String
    let personaContext: String
    let toolsContext: String
    let journalContext: String
    let taxonomy: String
    let userMessage: String
    
    func formatted() -> String {
        var bundleSections: [String] = []
        
        // 1. INSTRUCTIONS (Header)
        bundleSections.append(instructions)
        
        // 2. BOSS CONTEXT
        if !bossContext.isEmpty {
            bundleSections.append("=== BOSS CONTEXT ===")
            bundleSections.append(bossContext)
        }
        
        // 3. PERSONA COGNITIVE STRATEGY
        if !personaContext.isEmpty {
            bundleSections.append("=== PERSONA COGNITIVE STRATEGY ===")
            bundleSections.append(personaContext)
        }
        
        // 4. TOOLS CONTEXT
        if !toolsContext.isEmpty {
            bundleSections.append("=== TOOLS CONTEXT ===")
            bundleSections.append(toolsContext)
        }
        
        // 5. CONVERSATION HISTORY
        if !journalContext.isEmpty {
            bundleSections.append("=== CONVERSATION HISTORY ===")
            bundleSections.append(journalContext)
        }
        
        // 6. TAXONOMY STRUCTURE
        bundleSections.append("=== TAXONOMY STRUCTURE ===")
        bundleSections.append(taxonomy)
        
        // 7. USER MESSAGE
        bundleSections.append("=== USER MESSAGE ===")
        bundleSections.append(userMessage)
        
        return bundleSections.joined(separator: "\n\n")
    }
    
    func systemPrompt() -> String {
        var bundleSections: [String] = []
        
        // 1. INSTRUCTIONS (Header)
        bundleSections.append(instructions)
        
        // 2. BOSS CONTEXT
        if !bossContext.isEmpty {
            bundleSections.append("=== BOSS CONTEXT ===")
            bundleSections.append(bossContext)
        }
        
        // 3. PERSONA COGNITIVE STRATEGY
        if !personaContext.isEmpty {
            bundleSections.append("=== PERSONA COGNITIVE STRATEGY ===")
            bundleSections.append(personaContext)
        }
        
        // 4. TOOLS CONTEXT
        if !toolsContext.isEmpty {
            bundleSections.append("=== TOOLS CONTEXT ===")
            bundleSections.append(toolsContext)
        }
        
        // 5. CONVERSATION HISTORY
        if !journalContext.isEmpty {
            bundleSections.append("=== CONVERSATION HISTORY ===")
            bundleSections.append(journalContext)
        }
        
        // 6. TAXONOMY STRUCTURE
        bundleSections.append("=== TAXONOMY STRUCTURE ===")
        bundleSections.append(taxonomy)
        
        // Don't include USER MESSAGE in system prompt
        return bundleSections.joined(separator: "\n\n")
    }
}