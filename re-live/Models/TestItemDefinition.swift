//
//  TestItemDefinition.swift
//  re-live
//
//  Created by Suzie Kim on 6/13/25.
//

import Foundation

struct TestItemDefinition: Decodable {
    let id: String
    let canonicalName: String
    let aliases: [String]
    let category: String
    let normalRange: [Double]
    let unit: String
}
