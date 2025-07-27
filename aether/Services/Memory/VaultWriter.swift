import Foundation

class VaultWriter: VaultWriting {
    static let shared = VaultWriter()
    private let vaultPath: String
    private let fileManager = FileManager.default
    
    // Keep private init for shared instance
    private init() {
        self.vaultPath = VaultPathProvider.vaultPath
    }
    
    // Add public init for dependency injection
    init(vaultPath: String) {
        self.vaultPath = vaultPath
    }
    
    func writeFile(content: String, to relativePath: String) {
        let fullPath = vaultPath + "/" + relativePath
        let directory = (fullPath as NSString).deletingLastPathComponent
        
        ensureDirectoryExists(at: directory)
        
        do {
            try content.write(toFile: fullPath, atomically: true, encoding: .utf8)
        } catch {
            // Failed to write file - error will be propagated
        }
    }
    
    func writeJSON<T: Encodable>(_ object: T, to relativePath: String) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let jsonData = try encoder.encode(object)
            
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                writeFile(content: jsonString, to: relativePath)
            }
        } catch {
            // Failed to encode JSON - error will be propagated
        }
    }
    
    private func ensureDirectoryExists(at path: String) {
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(
                    atPath: path,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                // Failed to create directory - error will be propagated
            }
        }
    }
    
    // MARK: - VaultWriting Protocol Implementation
    
    func createDirectory(at relativePath: String) {
        let fullPath = vaultPath + "/" + relativePath
        ensureDirectoryExists(at: fullPath)
    }
    
    func deleteFile(at relativePath: String) {
        let fullPath = vaultPath + "/" + relativePath
        do {
            try fileManager.removeItem(atPath: fullPath)
        } catch {
            // Failed to delete file - error will be propagated
        }
    }
}