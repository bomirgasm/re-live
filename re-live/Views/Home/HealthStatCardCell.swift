//
//  HealthStatCardCell.swift
//  re-live
//
//  Created by Suzie Kim on 6/11/25.
//

import Foundation
import UIKit


final class HealthStatCardCell: UICollectionViewCell {
    static let identifier = "HealthStatCardCell"

    // MARK: - UI Components

    private let iconContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = UIColor.systemBlue
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 1
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let valueLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .label
        label.numberOfLines = 1
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    private let unitLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = 1
        label.setContentHuggingPriority(.required, for: .horizontal)
        return label
    }()

    private let statusIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: 14),
            imageView.heightAnchor.constraint(equalToConstant: 14)
        ])
        return imageView
    }()

    private let statusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup

    private func setupUI() {
        contentView.backgroundColor = UIColor.systemGray6
        contentView.layer.cornerRadius = 16
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.systemGray4.cgColor
        contentView.clipsToBounds = true

        iconContainer.addSubview(iconImageView)
        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 32),
            iconContainer.heightAnchor.constraint(equalToConstant: 32)
        ])

        let topStack = UIStackView(arrangedSubviews: [iconContainer, titleLabel])
        topStack.axis = .horizontal
        topStack.spacing = 8
        topStack.alignment = .center
        topStack.distribution = .fill

        let valueStack = UIStackView(arrangedSubviews: [valueLabel, unitLabel])
        valueStack.axis = .horizontal
        valueStack.spacing = 4
        valueStack.alignment = .lastBaseline
        valueStack.distribution = .fill

        let statusStack = UIStackView(arrangedSubviews: [statusIcon, statusLabel])
        statusStack.axis = .horizontal
        statusStack.spacing = 4
        statusStack.alignment = .center
        statusStack.distribution = .fill

        let verticalStack = UIStackView(arrangedSubviews: [topStack, valueStack, statusStack])
        verticalStack.axis = .vertical
        verticalStack.spacing = 8
        verticalStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(verticalStack)

        NSLayoutConstraint.activate([
            verticalStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            verticalStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            verticalStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            verticalStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }

    // MARK: - Configure

    func configure(title: String, value: String, unit: String, icon: String, status: String, statusColor: UIColor) {
        iconImageView.image = UIImage(systemName: icon)
        iconImageView.tintColor = UIColor(named: "Primary") ?? UIColor.systemBlue

        titleLabel.text = title
        valueLabel.text = value
        unitLabel.text = unit

        statusLabel.text = status
        statusLabel.textColor = statusColor

        let iconName = statusColor == .systemGreen ? "arrow.down" : "arrow.up"
        statusIcon.image = UIImage(systemName: iconName)
        statusIcon.tintColor = statusColor
    }
}

