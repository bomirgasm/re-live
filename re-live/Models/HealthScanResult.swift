//
//  HealthScanResult.swift
//  re-live
//
//  Created by Suzie Kim on 6/19/25.
//

import Foundation

struct HealthScanResult: Codable, Identifiable {
    var id: UUID  // 👈 새로 추가
    var patientName: String
    var doctorName: String?
    var clinicName: String?
    var testDate: String?
    var savedAt: String?
    var testItems: [TestItem]
    
    init(
        id: UUID = UUID(),
        patientName: String,
        doctorName: String?,
        clinicName: String?,
        testDate: String?,
        savedAt: String?,
        testItems: [TestItem]
    ) {
        self.id = id
        self.patientName = patientName
        self.doctorName = doctorName
        self.clinicName = clinicName
        self.testDate = testDate
        self.savedAt = savedAt
        self.testItems = testItems
    }
    
    // MARK: 디코딩 시 기존 데이터에 id 없으면 자동 생성
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(UUID.self, forKey: .id) ?? UUID()
        self.patientName = try container.decode(String.self, forKey: .patientName)
        self.doctorName = try container.decodeIfPresent(String.self, forKey: .doctorName)
        self.clinicName = try container.decodeIfPresent(String.self, forKey: .clinicName)
        self.testDate = try container.decode(String.self, forKey: .testDate)
        self.savedAt = try container.decodeIfPresent(String.self, forKey: .savedAt)
        self.testItems = try container.decode([TestItem].self, forKey: .testItems)
    }
    
    
}

extension HealthScanResult: Equatable {
    static func == (lhs: HealthScanResult, rhs: HealthScanResult) -> Bool {
        lhs.id == rhs.id
    }
}
