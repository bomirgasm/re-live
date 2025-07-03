//
//  HomeViewModel.swift
//  re-live
//
//  Created by Suzie Kim on 6/5/25.
//

//
//  HomeViewModel.swift
//  re-live
//
//  Created by Suzie Kim on 6/5/25.
//

import Foundation

final class HomeViewModel {
    /// Cached results loaded from local storage
    private(set) var results: [HealthScanResult] = []

    init() {
        refresh()
    }

    /// Reload all scan results from storage
    func refresh() {
        results = LocalStorageService.shared.loadAll()
    }

    /// Most recently saved scan result
    var latestResult: HealthScanResult? {
        results.last
    }

    /// Name to display in greeting
    var greetingName: String {
        latestResult?.patientName ?? "there"
    }

    /// Formatted date string used in greeting
    var greetingDateText: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter.string(from: Date())
    }

    /// Up to the three most recent results (newest first)
    var recentResults: [HealthScanResult] {
        let slice = results.suffix(3)
        return Array(slice.reversed())
    }

    /// Convenience for formatting dates from stored strings
    func formatted(date string: String?) -> String {
        guard let string = string else { return "" }
        let iso = DateFormatter()
        iso.dateFormat = "yyyy-MM-dd"
        if let date = iso.date(from: string) {
            let fmt = DateFormatter()
            fmt.dateStyle = .medium
            return fmt.string(from: date)
        }
        return string
    }
}
