//
//  RecordDetailViewController.swift
//  re-live
//
//  Created by Suzie Kim on 6/19/25.
//

import UIKit

final class RecordDetailViewController: UIViewController {
    private let result: HealthScanResult

    init(result: HealthScanResult) {
        self.result = result
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        populateContent()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 16

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    private func populateContent() {
        let title = UILabel()
        let dateText   = result.testDate   ?? "날짜 정보 없음"
        let doctorText = result.doctorName ?? "-"
        let hospitalText = result.clinicName ?? "-"
        title.text = "검진일: \(dateText)\n병원명: \(hospitalText)\n의사: \(doctorText)"
        title.numberOfLines = 0
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        contentStackView.addArrangedSubview(title)

        for item in result.testItems {
            let label = UILabel()
            label.text = "\(item.name): \(item.value) \(item.unit ?? "")"
            label.font = UIFont.systemFont(ofSize: 14)
            label.textColor = .label
            contentStackView.addArrangedSubview(label)
        }
    }
}
