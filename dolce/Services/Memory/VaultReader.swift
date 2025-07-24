import Foundation

class VaultReader: VaultReading {
    static let shared = VaultReader()
    private let vaultPath: String
    
    // Keep private init for shared instance
    private init() {
        self.vaultPath = VaultPathProvider.vaultPath
    }
    
    // Add public init for dependency injection
    init(vaultPath: String) {
        self.vaultPath = vaultPath
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
    
    // MARK: - VaultReading Protocol Implementation
    
    func fileExists(at path: String) -> Bool {
        let fullPath = vaultPath + "/" + path
        return FileManager.default.fileExists(atPath: fullPath)
    }
    
    func listFiles(at path: String) -> [String] {
        let directoryPath = vaultPath + "/" + path
        let fileManager = FileManager.default
        
        guard let urls = try? fileManager.contentsOfDirectory(
            at: URL(fileURLWithPath: directoryPath),
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return []
        }
        
        return urls.map { $0.lastPathComponent }
    }
}