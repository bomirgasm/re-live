//
//  TestItemMatcher.swift
//  re-live
//
//  Created by Suzie Kim on 6/13/25.
//

import Foundation

final class TestItemMatcher {
    
    private var definitions: [TestItemDefinition] = []
    
    init() {
        loadDefinitions()
    }

    private func loadDefinitions() {
        guard let url = Bundle.main.url(forResource: "test_item_definitions", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([TestItemDefinition].self, from: data)
        else {
            print("검사 정의 파일 로딩 실패")
            return
        }
        definitions = decoded
    }

    func matchItems(from text: String) -> [MatchedTestItem] {
        var results: [MatchedTestItem] = []

        let pattern = #"([가-힣A-Za-z0-9]+)[\s:]+([0-9.]+)[\s]*([^\s]*)"#
        let regex = try? NSRegularExpression(pattern: pattern)

        let lines = text.components(separatedBy: .newlines)

        for line in lines {
            guard let match = regex?.firstMatch(in: line, range: NSRange(location: 0, length: line.utf16.count)),
                  match.numberOfRanges >= 4 else {
                continue
            }

            let itemName = line.substring(with: match.range(at: 1))
            let value = line.substring(with: match.range(at: 2))
            let unit = line.substring(with: match.range(at: 3))

            // alias 매칭
            if let matchedDefinition = definitions.first(where: {
                $0.aliases.contains { $0.caseInsensitiveCompare(itemName) == .orderedSame }
            }) {
                let matched = MatchedTestItem(
                    id: matchedDefinition.id,
                    displayName: matchedDefinition.canonicalName,
                    value: value,
                    unit: unit.isEmpty ? matchedDefinition.unit : unit
                )
                results.append(matched)
            }
        }

        return results
    }
}
