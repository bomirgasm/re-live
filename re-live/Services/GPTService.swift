//
//  GPTService.swift
//  re-live
//
//  Created by Suzie Kim on 6/19/25.
//

import Foundation
import UIKit

final class GPTService {
    static let shared = GPTService()
    private init() {}

    private let apiKey: String = {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: filePath),
              let key = plist["OPENAI_API_KEY"] as? String else {
            fatalError("❌ OpenAI API 키를 Secrets.plist에서 불러올 수 없습니다.")
        }
        return key
    }()

    private let endpoint = URL(string: "https://api.openai.com/v1/chat/completions")!

    func analyze(ocrText: String, image: UIImage, completion: @escaping (Result<HealthScanResult, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            return completion(.failure(NSError(domain: "ImageError", code: -1)))
        }

        let base64Image = imageData.base64EncodedString()
        let imageContent: [String: Any] = [
            "type": "image_url",
            "image_url": [
                "url": "data:image/jpeg;base64,\(base64Image)",
                "detail": "high"
            ]
        ]

        let instructionContent: [String: Any] = [
            "type": "text",
            "text": """
            다음 OCR 텍스트와 이미지를 분석하여 아래 JSON 포맷만 출력하세요.  
            - 설명 없이 JSON만 출력할 것  
            - 백틱(```) 포함 금지  
            - 유효한 JSON 형식일 것  

            {
              "patientName": String,
              "testDate": "yyyy-MM-dd",
              "clinicName": String,
              "doctorName": String,
              "testItems": [{ "name": String, "value": String, "unit": String? }]
            }

            누락되거나 잘못된 부분이 있으면 이미지를 참고해 보완해주세요.
            반드시 JSON만 출력하고, 설명은 생략하세요.
            """
        ]

        let ocrTextContent: [String: Any] = [
            "type": "text",
            "text": ocrText
        ]

        let messages: [[String: Any]] = [
            [
                "role": "user",
                "content": [instructionContent, ocrTextContent, imageContent]
            ]
        ]

        let requestBody: [String: Any] = [
            "model": "gpt-4o",
            "messages": messages,
            "temperature": 0.2
        ]

        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            return completion(.failure(error))
        }

        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let data = data else {
                return completion(.failure(NSError(domain: "NoData", code: -2)))
            }

            do {
                let gptResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
                guard let content = gptResponse.choices.first?.message.content,
                      let jsonData = content.data(using: .utf8) else {
                    return completion(.failure(NSError(domain: "EmptyContent", code: -3)))
                }

                let result = try JSONDecoder().decode(HealthScanResult.self, from: jsonData)
                print("✅ 구조화 성공:\n\(result)")
                completion(.success(result))
            } catch {
                print("❌ 디코딩 실패: \(error)")
                completion(.failure(error))
            }
        }.resume()
    }
}

struct OpenAIResponse: Codable {
    struct Choice: Codable {
        struct Message: Codable {
            let content: String
        }
        let message: Message
    }
    let choices: [Choice]
}
