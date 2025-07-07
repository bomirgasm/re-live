//
//  RecordTableViewCell.swift
//  re-live
//
//  Created by Suzie Kim on 7/3/25.
//

import Foundation
import UIKit

class RecordTableViewCell: UITableViewCell {
    static let reuseIdentifier = "RecordTableViewCell"
    
    // 카드 컨테이너 (원래 makeRecordCard 내부 container)
    private let cardContainer = UIView()

    // 스택뷰만 재사용하는 편이 간단합니다:
    private lazy var cardStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [])
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    // MARK: - 초기화
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        
        // 카드 컨테이너 스타일
        cardContainer.backgroundColor = .white
        cardContainer.layer.cornerRadius = 16
        cardContainer.layer.shadowColor = UIColor.black.cgColor
        cardContainer.layer.shadowOpacity = 0.08
        cardContainer.layer.shadowRadius = 8
        cardContainer.layer.shadowOffset = CGSize(width: 0, height: 4)
        cardContainer.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(cardContainer)
        cardContainer.addSubview(cardStack)
        
        NSLayoutConstraint.activate([
            // container 마진
            cardContainer.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            cardContainer.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            cardContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            cardContainer.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // stack 뷰 핀
            cardStack.topAnchor.constraint(equalTo: cardContainer.topAnchor, constant: 20),
            cardStack.bottomAnchor.constraint(equalTo: cardContainer.bottomAnchor, constant: -20),
            cardStack.leadingAnchor.constraint(equalTo: cardContainer.leadingAnchor, constant: 20),
            cardStack.trailingAnchor.constraint(equalTo: cardContainer.trailingAnchor, constant: -20),
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:)") }

    /// 원래 makeRecordCard(from:) 의 로직 중, cardStack 부분만 담아주세요.
    func configure(with result: HealthScanResult) {
        // 1) 기존 항목 삭제
        cardStack.arrangedSubviews.forEach { v in
            cardStack.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        // 2) 상단 row: 제목+부제목 + 아이콘
        let titleLabel = UILabel()
        titleLabel.text = "Annual Check-up"
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        
        let subLabel = UILabel()
        let dateText   = result.testDate   ?? "날짜 정보 없음"
        let doctorText = result.doctorName ?? "-"
        subLabel.text = "\(dateText) • \(doctorText)"
        subLabel.font = .systemFont(ofSize: 13, weight: .regular)
        subLabel.textColor = .secondaryLabel
        
        let vStack = UIStackView(arrangedSubviews: [titleLabel, subLabel])
        vStack.axis = .vertical
        vStack.spacing = 4
        
        let icon = UIImageView(image: UIImage(systemName: "doc.text"))
        icon.tintColor = .white
        icon.backgroundColor = .systemBlue
        icon.layer.cornerRadius = 20
        icon.clipsToBounds = true
        icon.contentMode = .center
        icon.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            icon.widthAnchor.constraint(equalToConstant: 40),
            icon.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        let topRow = UIStackView(arrangedSubviews: [vStack, icon])
        topRow.axis = .horizontal
        topRow.alignment = .center
        topRow.distribution = .equalSpacing
        
        // 3) 태그 뱃지
        let tagStack = UIStackView()
        tagStack.axis = .horizontal
        tagStack.spacing = 8
        
        for item in result.testItems.prefix(3) {
            let badge = PaddingLabel()
            badge.text = "\(item.name): \(item.value) \(item.unit ?? "")"
            badge.font = .systemFont(ofSize: 12, weight: .medium)
            badge.textColor = .white
            badge.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.8)
            badge.layer.cornerRadius = 12
            badge.clipsToBounds = true
            badge.insets = UIEdgeInsets(top: 4, left: 10, bottom: 4, right: 10)
            tagStack.addArrangedSubview(badge)
        }
        
        // 4) cardStack에 추가
        cardStack.addArrangedSubview(topRow)
        cardStack.addArrangedSubview(tagStack)
    }
}
