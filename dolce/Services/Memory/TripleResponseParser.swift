import Foundation

class TripleResponseParser {
    static let shared = TripleResponseParser()
    
    private init() {}
    
    func parse(_ response: String) -> TripleResponse {
        // First try standard parsing
        if let parsed = TripleResponse.parse(from: response) {
            print("[TripleResponseParser] Successfully parsed triple response")
            return parsed
        }
        
        // Log for debugging
        print("[TripleResponseParser] Warning: Response doesn't match expected format")
        print("[TripleResponseParser] Response preview: \(String(response.prefix(200)))...")
        
        // Fallback parsing - try to extract what we can
        let mainResponse = extractMainResponse(from: response)
        let taxonomyAnalysis = extractTaxonomyAnalysis(from: response)
        let machineTrim = extractMachineTrim(from: response)
        
        // Check what we found
        if !mainResponse.isEmpty {
            print("[TripleResponseParser] Found main response section")
        }
        if !taxonomyAnalysis.isEmpty {
            print("[TripleResponseParser] Found taxonomy analysis section")
        }
        if !machineTrim.isEmpty {
            print("[TripleResponseParser] Found machine trim section")
        }
        
        // If we found nothing structured, treat entire response as main
        if mainResponse.isEmpty && taxonomyAnalysis.isEmpty && machineTrim.isEmpty {
            print("[TripleResponseParser] No structured sections found, using entire response as main")
            return TripleResponse(
                taxonomyAnalysis: "No taxonomy analysis provided",
                mainResponse: response.trimmingCharacters(in: .whitespacesAndNewlines),
                machineTrim: "No machine trim provided"
            )
        }
        
        return TripleResponse(
            taxonomyAnalysis: taxonomyAnalysis.isEmpty ? "No taxonomy analysis provided" : taxonomyAnalysis,
            mainResponse: mainResponse.isEmpty ? response : mainResponse,
            machineTrim: machineTrim.isEmpty ? "No machine trim provided" : machineTrim
        )
    }
    
    private func extractMainResponse(from text: String) -> String {
        if let range = text.range(of: "---MAIN_RESPONSE---") {
            let afterMarker = String(text[range.upperBound...])
            if let endRange = afterMarker.range(of: "---MACHINE_TRIM---") {
                return String(afterMarker[..<endRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return afterMarker.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }
    
    private func extractTaxonomyAnalysis(from text: String) -> String {
        if let range = text.range(of: "---TAXONOMY_ANALYSIS---") {
            let afterMarker = String(text[range.upperBound...])
            if let endRange = afterMarker.range(of: "---MAIN_RESPONSE---") {
                return String(afterMarker[..<endRange.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
            return afterMarker.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }
    
    private func extractMachineTrim(from text: String) -> String {
        if let range = text.range(of: "---MACHINE_TRIM---") {
            let afterMarker = String(text[range.upperBound...])
            return afterMarker.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return ""
    }
}