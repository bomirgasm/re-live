//
//  EditScanViewModel.swift
//  re-live
//
//  Created by Suzie Kim on 6/19/25.
//

import Foundation
import UIKit

final class EditScanViewModel: ObservableObject {
    @Published var result: HealthScanResult?
    @Published var isLoading = false
    @Published var errorMessage: String?

    func analyzeOCRText(ocrText: String, previewImage: UIImage) {
        isLoading = true
        errorMessage = nil

//        GPTService.shared.analyze(ocrText: text, image: previewImage) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                switch result {
//                case .success(let data):
//                    var withSavedDate = data
//                    withSavedDate.savedAt = Self.today()
//                    self?.result = withSavedDate
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                }
//            }
//        }
        
        GPTService.shared.analyze(ocrText: ocrText, image: previewImage) { result in
            switch result {
            case .success(let scanResult):
                print("✅ 구조화 결과: \(scanResult)")
                DispatchQueue.main.async {
                    self.result = scanResult
                }
            case .failure(let error):
                print("❌ 분석 실패: \(error.localizedDescription)")
            }
        }

    }

    private static func today() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
}

//import Foundation
//
//class EditScanViewModel {
//    @Published var scanResult: HealthScanResult?
//    @Published var isLoading: Bool = false
//    @Published var errorMessage: String?
//
//    private let gptService = GPTService()
//
//    func analyzeScan(ocrText: String, completion: @escaping () -> Void) {
//        isLoading = true
//        errorMessage = nil
//        gptService.requestAnalysis(for: ocrText) { [weak self] result in
//            DispatchQueue.main.async {
//                self?.isLoading = false
//                switch result {
//                case .success(let parsedResult):
//                    self?.scanResult = parsedResult
//                case .failure(let error):
//                    self?.errorMessage = error.localizedDescription
//                }
//                completion()
//            }
//        }
//    }
//}

