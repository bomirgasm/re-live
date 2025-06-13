//
//  TestItemCell.swift
//  re-live
//
//  Created by Suzie Kim on 6/5/25.
//

import UIKit

class TestItemCell: UITableViewCell {
    
    private let nameField = UITextField()
    private let valueField = UITextField()
    private let unitField = UITextField()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with item: TestItem) {
        nameField.text = item.name
        valueField.text = item.value
        unitField.text = item.unit
    }

    private func setupUI() {
        nameField.placeholder = "Test Name"
        valueField.placeholder = "Value"
        unitField.placeholder = "Unit"

        nameField.borderStyle = .roundedRect
        valueField.borderStyle = .roundedRect
        unitField.borderStyle = .roundedRect

        let stack = UIStackView(arrangedSubviews: [nameField, valueField, unitField])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
}
