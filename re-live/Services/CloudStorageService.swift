//
//  CloudStorageService.swift
//  re-live
//
//  Created by Suzie Kim on 7/3/25.
//

import Foundation

class CloudStorageService {
    static let shared = CloudStorageService()

    func upload(_ result: HealthScanResult, completion: @escaping (Result<Void, Error>) -> Void) {
        // Firebase, AWS, 자체 서버 등으로 업로드
    }

    func fetchAll(completion: @escaping (Result<[HealthScanResult], Error>) -> Void) {
        // 클라우드에서 전체 리스트 내려받기
    }
}
