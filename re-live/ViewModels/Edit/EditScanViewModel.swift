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
        
        GPTService.shared.analyze(ocrText: ocrText, image: previewImage) { result in
            switch result {
            case .success(let scanResult):
                print("구조화 결과: \(scanResult)")
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

    func saveResult() {
        guard let result = result else {
            print("❌ 저장할 결과가 없습니다")
            return
        }
        print("✅ 저장할 결과 있음:\n\(result)")  // 실제 저장 대상 확인
        LocalStorageService.shared.save(result)
        print("✅ 저장됨: \(result)")
    }

}

