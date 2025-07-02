//
//  RecordListViewController.swift
//  re-live
//
//  Created by Suzie Kim on 6/5/25.
//

import UIKit

final class RecordsViewController: UIViewController {
    private var recentResult: HealthScanResult? {
        LocalStorageService.shared.loadAll().last
    }

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()
    
    private let allResults: [HealthScanResult] = LocalStorageService.shared.loadAll()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        loadContent()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 24

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 24),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    private func loadContent() {
        guard let result = recentResult else { return }

        // 제목
        let titleLabel = UILabel()
        titleLabel.text = "My Records"
        titleLabel.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        titleLabel.textColor = .label
        contentStackView.addArrangedSubview(titleLabel)

        // 카드
        let recordCard = makeRecordCard(from: result)
        contentStackView.addArrangedSubview(recordCard)
    }

    private func makeRecordCard(from result: HealthScanResult) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 16
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOpacity = 0.08
        container.layer.shadowRadius = 8
        container.layer.shadowOffset = CGSize(width: 0, height: 4)
        container.translatesAutoresizingMaskIntoConstraints = false
        container.isUserInteractionEnabled = true
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(cardTapped(_:)))
            container.addGestureRecognizer(tap)
            container.tag = allResults.firstIndex(where: { $0.id == result.id }) ?? 0

        // 왼쪽 텍스트 스택
        let titleLabel = UILabel()
        titleLabel.text = "Annual Check-up"
        titleLabel.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label

        let subLabel = UILabel()
        subLabel.text = "\(result.testDate) • \(result.doctorName)"
        subLabel.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        subLabel.textColor = .secondaryLabel

        let vStack = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        vStack.axis = .vertical
        vStack.spacing = 4

        // 오른쪽 아이콘
        let icon = UIImageView(image: UIImage(systemName: "doc.text"))
        icon.tintColor = .white
        icon.backgroundColor = UIColor.systemBlue
        icon.layer.cornerRadius = 20
        icon.clipsToBounds = true
        icon.contentMode = .center
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 40),
            icon.heightAnchor.constraint(equalToConstant: 40)
        ])

        // 상단 가로 스택
        let topRow = UIStackView(arrangedSubviews: [vStack, icon])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.distribution = .equalSpacing

        // 태그 뱃지들
        let tagStack = UIStackView()
        tagStack.axis = .horizontal
        tagStack.spacing = 8

        for tag in result.testItems.prefix(3) {
            let badge = PaddingLabel()
            badge.text = "\(tag.name): \(tag.value) \(tag.unit ?? "")"
            badge.font = UIFont.systemFont(ofSize: 12, weight: .medium)
            badge.textColor = .white
            badge.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
            badge.layer.cornerRadius = 12
            badge.clipsToBounds = true
            badge.insets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
            tagStack.addArrangedSubview(badge)
        }

        // 전체 카드 스택
        let cardStack = UIStackView(arrangedSubviews: [topRow, tagStack])
        cardStack.axis = .vertical
        cardStack.spacing = 16
        cardStack.translatesAutoresizingMaskIntoConstraints = false

        container.addSubview(cardStack)
        NSLayoutConstraint.activate([
            cardStack.topAnchor.constraint(equalTo: container.topAnchor, constant: 20),
            cardStack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -20),
            cardStack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 20),
            cardStack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -20)
        ])

        return container
    }
    
    @objc private func cardTapped(_ sender: UITapGestureRecognizer) {
        guard let index = sender.view?.tag else { return }
        let selectedResult = allResults[index]
        let detailVC = RecordDetailViewController(result: selectedResult)
        navigationController?.pushViewController(detailVC, animated: true)
    }

}

private extension UILabel {
    func setPadding(horizontal: CGFloat, vertical: CGFloat) {
        let insets = UIEdgeInsets(top: vertical, left: horizontal, bottom: vertical, right: horizontal)
        self.drawText(in: bounds.inset(by: insets))
    }
}
