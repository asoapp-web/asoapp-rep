import Foundation

// MARK: - Memory Data Processor
// Уникальный класс для обфускации данных (XOR + Base64)
final class MemoryDataProcessor {
    
    // Уникальный ключ для проекта MemoryCard
    private static let memoryTransformKey = "MemoryCard_DataTransform_2024_Key!"
    
    /// Обфускация строки (XOR + Base64)
    static func memoryTransform(_ memoryInput: String) -> String? {
        guard !memoryInput.isEmpty else {
            print("📝 [MemoryDataProcessor] Empty input received")
            return nil
        }
        
        let memoryKeyBytes = Array(memoryTransformKey.utf8)
        let memoryInputBytes = Array(memoryInput.utf8)
        var memoryOutputBytes = [UInt8]()
        
        for (memoryIndex, memoryByte) in memoryInputBytes.enumerated() {
            let memoryKeyByte = memoryKeyBytes[memoryIndex % memoryKeyBytes.count]
            memoryOutputBytes.append(memoryByte ^ memoryKeyByte)
        }
        
        let memoryResult = Data(memoryOutputBytes).base64EncodedString()
        print("📝 [MemoryDataProcessor] Data transformed, length: \(memoryResult.count)")
        return memoryResult
    }
    
    /// Деобфускация строки (Base64 + XOR)
    static func memoryRestore(_ memoryInput: String) -> String? {
        guard let memoryData = Data(base64Encoded: memoryInput) else {
            print("📝 [MemoryDataProcessor] Failed to decode input")
            return nil
        }
        
        let memoryKeyBytes = Array(memoryTransformKey.utf8)
        let memoryInputBytes = Array(memoryData)
        var memoryOutputBytes = [UInt8]()
        
        for (memoryIndex, memoryByte) in memoryInputBytes.enumerated() {
            let memoryKeyByte = memoryKeyBytes[memoryIndex % memoryKeyBytes.count]
            memoryOutputBytes.append(memoryByte ^ memoryKeyByte)
        }
        
        guard let memoryResult = String(bytes: memoryOutputBytes, encoding: .utf8) else {
            print("📝 [MemoryDataProcessor] Failed to convert bytes to string")
            return nil
        }
        
        print("📝 [MemoryDataProcessor] Data restored successfully")
        return memoryResult
    }
}
