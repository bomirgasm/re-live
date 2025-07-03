//
//  GreetingCell.swift
//  re-live
//
//  Created by Suzie Kim on 6/11/25.
//

import Foundation

import UIKit

final class GreetingCell: UICollectionViewCell {
    static let identifier = "GreetingCell"

    private let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .darkText
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(greetingLabel)
        contentView.addSubview(dateLabel)

        NSLayoutConstraint.activate([
            greetingLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            greetingLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            greetingLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),

            dateLabel.topAnchor.constraint(equalTo: greetingLabel.bottomAnchor, constant: 4),
            dateLabel.leadingAnchor.constraint(equalTo: greetingLabel.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: greetingLabel.trailingAnchor),
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    func configure(greeting: String, dateText: String) {
        greetingLabel.text = greeting
        dateLabel.text = dateText
    }
}

