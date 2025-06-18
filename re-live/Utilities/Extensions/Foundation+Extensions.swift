//
//  Foundation+Extensions.swift
//  re-live
//
//  Created by Suzie Kim on 6/13/25.
//

import Foundation

extension String {
    func substring(with nsRange: NSRange) -> String {
        guard let range = Range(nsRange, in: self) else { return "" }
        return String(self[range])
    }
}
