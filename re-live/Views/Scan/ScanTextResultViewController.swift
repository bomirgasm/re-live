//
//  ScanTextResultViewController.swift
//  re-live
//
//  Created by Suzie Kim on 6/12/25.
//

//import Foundation
//import UIKit
//
//final class ScanTextResultViewController: UIViewController {
//    
//    private let textView = UITextView()
//    private let recognizedText: String
//    
//    init(recognizedText: String) {
//        self.recognizedText = recognizedText
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .systemBackground
//        setupTextView()
//    }
//    
//    private func setupTextView() {
//        textView.text = recognizedText
//        textView.isEditable = false
//        textView.font = UIFont.systemFont(ofSize: 16)
//        textView.translatesAutoresizingMaskIntoConstraints = false
//        
//        view.addSubview(textView)
//        NSLayoutConstraint.activate([
//            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
//            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
//        ])
//    }
//}

import UIKit

final class ScanTextResultViewController: UIViewController {

    private let recognizedText: String
    
    init(recognizedText: String) {
        self.recognizedText = recognizedText
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Scan Result"
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .left
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "June 11, 2025"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.textAlignment = .left
        return label
    }()

    private let resultTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = UIColor.systemGray6
        textView.layer.cornerRadius = 12
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        return textView
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.backgroundColor = .systemGray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()

    private let buttonStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.spacing = 12
        return stack
    }()

    private let mainStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        return stack
    }()

    var scannedText: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupLayout()
        resultTextView.text = recognizedText
    }

    private func setupLayout() {
        buttonStack.addArrangedSubview(editButton)
        buttonStack.addArrangedSubview(deleteButton)
        buttonStack.addArrangedSubview(saveButton)

        mainStack.translatesAutoresizingMaskIntoConstraints = false
        mainStack.addArrangedSubview(headerLabel)
        mainStack.addArrangedSubview(dateLabel)
        mainStack.addArrangedSubview(resultTextView)
        mainStack.addArrangedSubview(buttonStack)

        view.addSubview(mainStack)

        NSLayoutConstraint.activate([
            mainStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            mainStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            mainStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            resultTextView.heightAnchor.constraint(equalToConstant: 300),
            saveButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}
