//
//  HealthScanResult.swift
//  re-live
//
//  Created by Suzie Kim on 6/19/25.
//

import Foundation

struct HealthScanResult: Codable {
    var patientName: String
    var testDate: String    // "yyyy-MM-dd"
    var savedAt: String?
    var clinicName: String?
    var doctorName: String?
    var testItems: [TestItem]
}


