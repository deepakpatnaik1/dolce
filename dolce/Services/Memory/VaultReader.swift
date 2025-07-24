import Foundation

class VaultReader {
    static let shared = VaultReader()
    private let vaultPath: String
    
    private init() {
        self.vaultPath = VaultPathProvider.vaultPath
    }
    
    func readFile(at relativePath: String) -> String? {
        let fullPath = vaultPath + "/" + relativePath
        do {
            return try String(contentsOfFile: fullPath, encoding: .utf8)
        } catch {
            print("Failed to read file at \(fullPath): \(error)")
            return nil
        }
    }
    
    func readAllFiles(in directory: String, withExtension ext: String = "md") -> [String] {
        let directoryPath = vaultPath + "/" + directory
        let fileManager = FileManager.default
        
        guard let urls = try? fileManager.contentsOfDirectory(
            at: URL(fileURLWithPath: directoryPath),
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        var contents: [String] = []
        
        for url in urls where url.pathExtension == ext {
            if let content = try? String(contentsOf: url, encoding: .utf8) {
                contents.append(content)
            }
        }
        
        return contents
    }
    
    func readJSON<T: Decodable>(at relativePath: String, as type: T.Type) -> T? {
        guard let jsonString = readFile(at: relativePath),
              let jsonData = jsonString.data(using: .utf8) else {
            return nil
        }
        
        do {
            return try JSONDecoder().decode(type, from: jsonData)
        } catch {
            print("Failed to decode JSON at \(relativePath): \(error)")
            return nil
        }
    }
}