//
//  LocalStorageService.swift
//  re-live
//
//  Created by Suzie Kim on 6/5/25.
//

import Foundation

final class LocalStorageService {
    static let shared = LocalStorageService()
    private init() {}
    
    private let key = "savedScanResults"
    
    func save(_ result: HealthScanResult) {
        var results = loadAll()
        if let last = results.last, last.id == result.id {
            print("⚠️ 중복된 레코드, 저장 취소")
            return
        }
        results.append(result)
        
        if let data = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(data, forKey: key)
            print("✅ 저장 완료: \(results.count)개의 결과가 저장됨")  // 저장 완료 확인
        }
        else {
            print("❌ 저장 실패")
        }
    }
    
    func loadAll() -> [HealthScanResult] {
        guard let data = UserDefaults.standard.data(forKey: key),
              let results = try? JSONDecoder().decode([HealthScanResult].self, from: data) else {
            return []
        }
        return results
    }
}

extension LocalStorageService {
    /// id 일치하는 결과 제거
    func delete(id: UUID) {
        var results = loadAll()
        if let idx = results.firstIndex(where: { $0.id == id }) {
            results.remove(at: idx)
            saveAll(results)
            print("🗑️ 삭제: index=\(idx), 남은 개수=\(results.count)")
        }
    }
    
    private func saveAll(_ results: [HealthScanResult]) {
        if let data = try? JSONEncoder().encode(results) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
}

