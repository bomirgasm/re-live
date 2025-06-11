//
//  OCRService.swift
//  re-live
//
//  Created by Suzie Kim on 6/5/25.
//

import Foundation
import Vision
import UIKit

/// Service responsible for performing OCR on provided images using Vision.
final class OCRService {

    static let shared = OCRService()

    private let queue = DispatchQueue(label: "OCRServiceQueue", qos: .userInitiated)

    enum OCRServiceError: Error {
        case invalidImage
    }

    /// Recognizes text from the given image and returns the concatenated result.
    func recognizeText(in image: UIImage, completion: @escaping (Result<OCRResult, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(OCRServiceError.invalidImage))
            return
        }

        queue.async {
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
                

                let text = request.results?
                    .compactMap { ($0 as? VNRecognizedTextObservation)?.topCandidates(1).first?.string }
                    .joined(separator: "\n") ?? ""

                DispatchQueue.main.async {
                    completion(.success(OCRResult(text: text)))
                }
            }

            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ko"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
