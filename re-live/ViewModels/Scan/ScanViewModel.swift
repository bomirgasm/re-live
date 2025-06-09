//
//  ScanViewModel.swift
//  re-live
//
//  Created by Suzie Kim on 6/5/25.
//

import UIKit
import Combine

class ScanViewModel: ObservableObject {
    @Published var results: [String] = []
    @Published var isLoading: Bool = false
    @Published var error: Error?

    private let ocrService: OCRService
    private var cancellables = Set<AnyCancellable>()

    init(ocrService: OCRService = OCRService()) {
        self.ocrService = ocrService
    }

    func performOCR(on images: [UIImage]) {
        isLoading = true
        ocrService.recognizeText(from: images) { [weak self] result in
            guard let self = self else { return }
            self.isLoading = false
            switch result {
            case .success(let texts):
                self.results = texts
            case .failure(let error):
                self.error = error
            }
        }
    }

    func handleError(_ error: Error) {
        self.error = error
    }
}
