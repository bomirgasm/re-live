//
//  FirebaseService.swift
//  re-live
//
//  Created by Suzie Kim on 6/5/25.
//

import Foundation
import FirebaseFirestore

final class FirebaseService {

    static let shared = FirebaseService()
    private init() {}

    private let db = Firestore.firestore()

    /// Load stored records for a given user id.
    /// Records are stored under `users/{uid}/records` collection.
    func loadRecords(for uid: String, completion: @escaping ([HealthScanResult]) -> Void) {
        db.collection("users").document(uid).collection("records").getDocuments { snapshot, _ in
            guard let documents = snapshot?.documents else {
                completion([])
                return
            }

            let decoder = JSONDecoder()
            let results: [HealthScanResult] = documents.compactMap { doc in
                do {
                    let data = try JSONSerialization.data(withJSONObject: doc.data())
                    return try decoder.decode(HealthScanResult.self, from: data)
                } catch {
                    print("Failed to decode record: \(error)")
                    return nil
                }
            }

            completion(results)
        }
    }
}
