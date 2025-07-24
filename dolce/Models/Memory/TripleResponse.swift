import Foundation

struct TripleResponse {
    let taxonomyAnalysis: String
    let mainResponse: String
    let machineTrim: String
    
    static func parse(from rawResponse: String) -> TripleResponse? {
        let sections = rawResponse.components(separatedBy: "---")
        
        var taxonomyAnalysis = ""
        var mainResponse = ""
        var machineTrim = ""
        
        var currentSection = ""
        
        for section in sections {
            let trimmed = section.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmed == "TAXONOMY_ANALYSIS" {
                currentSection = "taxonomy"
            } else if trimmed == "MAIN_RESPONSE" {
                currentSection = "main"
            } else if trimmed == "MACHINE_TRIM" {
                currentSection = "trim"
            } else if !trimmed.isEmpty {
                switch currentSection {
                case "taxonomy":
                    taxonomyAnalysis = trimmed
                case "main":
                    mainResponse = trimmed
                case "trim":
                    machineTrim = trimmed
                default:
                    break
                }
            }
        }
        
        guard !taxonomyAnalysis.isEmpty && !mainResponse.isEmpty && !machineTrim.isEmpty else {
            return nil
        }
        
        return TripleResponse(
            taxonomyAnalysis: taxonomyAnalysis,
            mainResponse: mainResponse,
            machineTrim: machineTrim
        )
    }
}