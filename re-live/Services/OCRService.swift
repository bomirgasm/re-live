//
//  OCRService.swift
//  re-live
//
//  Created by Suzie Kim on 6/5/25.
//

import UIKit
import Vision

class OCRService {
    func recognizeText(from images: [UIImage], completion: @escaping (Result<[String], Error>) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var recognizedStrings: [String] = []
            for image in images {
                guard let cgImage = image.cgImage else { continue }
                let request = VNRecognizeTextRequest()
                request.recognitionLevel = .accurate
                request.usesLanguageCorrection = true
                let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
                do {
                    try handler.perform([request])
                    let texts = (request.results)?.compactMap { $0.topCandidates(1).first?.string } ?? []
                    recognizedStrings.append(texts.joined(separator: "\n"))
                } catch {
                    DispatchQueue.main.async {
                        completion(.failure(error))
                    }
                    return
                }
            }
            DispatchQueue.main.async {
                completion(.success(recognizedStrings))
            }
        }
    }
}
