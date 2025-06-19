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
