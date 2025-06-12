//
//  RecordCard.swift
//  re-live
//
//  Created by Suzie Kim on 6/11/25.
//

import UIKit

class RecordCard: UIView {

    // MARK: - UI Components

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let iconContainer = UIView()
    private let iconImageView = UIImageView()
    private let tagContainer = UIStackView()

    // MARK: - Init

    init(title: String, subtitle: String, tags: [String], icon: UIImage? = nil, iconColor: UIColor = UIColor(hex: "#007AFF")) {
        super.init(frame: .zero)
        setupUI()
        configure(title: title, subtitle: subtitle, tags: tags, icon: icon, iconColor: iconColor)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configuration

    private func configure(title: String, subtitle: String, tags: [String], icon: UIImage?, iconColor: UIColor) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
        iconImageView.image = icon ?? UIImage(systemName: "doc.text")
        iconImageView.tintColor = iconColor

        tagContainer.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tag in tags {
            let tagLabel = PaddingLabel()
            tagLabel.text = tag
            tagLabel.font = .systemFont(ofSize: 12)
            tagLabel.textColor = .darkGray
            tagLabel.backgroundColor = UIColor.systemGray5
            tagLabel.layer.cornerRadius = 12
            tagLabel.clipsToBounds = true
            tagContainer.addArrangedSubview(tagLabel)
        }
    }

    // MARK: - UI Setup

    private func setupUI() {
        self.backgroundColor = .white
        self.layer.cornerRadius = 12
        self.layer.borderColor = UIColor.systemGray4.cgColor
        self.layer.borderWidth = 1
        self.layer.shadowOpacity = 0.03
        self.layer.shadowRadius = 2
        self.layer.shadowOffset = .init(width: 0, height: 1)

        self.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label

        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = .gray

        iconContainer.backgroundColor = UIColor.systemBlue.withAlphaComponent(0.1)
        iconContainer.layer.cornerRadius = 16
        iconContainer.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconContainer.addSubview(iconImageView)

        NSLayoutConstraint.activate([
            iconImageView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
            iconContainer.widthAnchor.constraint(equalToConstant: 32),
            iconContainer.heightAnchor.constraint(equalToConstant: 32)
        ])

        let headerStack = UIStackView()
        headerStack.axis = .horizontal
        headerStack.alignment = .top
        headerStack.distribution = .equalSpacing
        headerStack.addArrangedSubview({
            let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
            stack.axis = .vertical
            stack.spacing = 2
            return stack
        }())
        headerStack.addArrangedSubview(iconContainer)

        tagContainer.axis = .horizontal
        tagContainer.spacing = 8
        tagContainer.alignment = .leading
        tagContainer.distribution = .fillProportionally
        tagContainer.translatesAutoresizingMaskIntoConstraints = false
        tagContainer.isLayoutMarginsRelativeArrangement = true
        tagContainer.layoutMargins = .init(top: 0, left: 0, bottom: 0, right: 0)
//        tagContainer.wrapToMultilineIfNeeded()

        let mainStack = UIStackView(arrangedSubviews: [headerStack, tagContainer])
        mainStack.axis = .vertical
        mainStack.spacing = 12
        mainStack.translatesAutoresizingMaskIntoConstraints = false

        self.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            mainStack.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            mainStack.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            mainStack.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12)
        ])
    }
}
