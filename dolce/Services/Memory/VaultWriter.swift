import Foundation

class VaultWriter {
    static let shared = VaultWriter()
    private let vaultPath: String
    private let fileManager = FileManager.default
    
    private init() {
        self.vaultPath = VaultPathProvider.vaultPath
    }
    
    func writeFile(content: String, to relativePath: String) {
        let fullPath = vaultPath + "/" + relativePath
        let directory = (fullPath as NSString).deletingLastPathComponent
        
        ensureDirectoryExists(at: directory)
        
        do {
            try content.write(toFile: fullPath, atomically: true, encoding: .utf8)
        } catch {
            print("Failed to write file at \(fullPath): \(error)")
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
            print("Failed to encode JSON for \(relativePath): \(error)")
        }
    }
    
    func ensureDirectoryExists(at path: String) {
        if !fileManager.fileExists(atPath: path) {
            do {
                try fileManager.createDirectory(
                    atPath: path,
                    withIntermediateDirectories: true,
                    attributes: nil
                )
            } catch {
                print("Failed to create directory at \(path): \(error)")
            }
        }
    }
}