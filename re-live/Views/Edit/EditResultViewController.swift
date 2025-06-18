//  EditResultViewController.swift
//  re-live
//
//  Created by Suzie Kim on 6/12/25.


import UIKit

class EditResultViewController: UIViewController {

    var ocrResult: OCRResult?
    var previewImage: UIImage?
    var scanTitle: String = "Blood Test Results"

    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    private let headerLabel: UILabel = {
        let label = UILabel()
        label.text = "Review Scan Results"
        label.font = UIFont.systemFont(ofSize: 22, weight: .semibold)
        label.textColor = .label
        return label
    }()

    private let subHeaderLabel: UILabel = {
        let label = UILabel()
        label.text = "Edit any incorrect values before saving"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()

    private let previewCard = UIControl()
    private let previewImageView = UIImageView()
    private let previewTitleLabel = UILabel()
    private let previewDateLabel = UILabel()

    private let testsContainerView = UIStackView()

    private let addTestButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("➕ Add another test", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        return button
    }()

    private let rescanButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Rescan", for: .normal)
        button.setTitleColor(UIColor.systemBlue, for: .normal)
        button.layer.borderColor = UIColor.systemBlue.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()

    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save Record", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
    }

    private func setupUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.axis = .vertical
        contentStackView.spacing = 16
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])

        contentStackView.addArrangedSubview(headerLabel)
        contentStackView.addArrangedSubview(subHeaderLabel)
        contentStackView.addArrangedSubview(createPreviewCard())

        testsContainerView.axis = .vertical
        testsContainerView.spacing = 12
        contentStackView.addArrangedSubview(testsContainerView)
        contentStackView.setCustomSpacing(24, after: testsContainerView)
        contentStackView.addArrangedSubview(addTestButton)

        let buttonStack = UIStackView(arrangedSubviews: [rescanButton, saveButton])
        buttonStack.axis = .horizontal
        buttonStack.spacing = 12
        buttonStack.distribution = .fillEqually
        contentStackView.addArrangedSubview(buttonStack)

        addTestButton.addTarget(self, action: #selector(addTestRow), for: .touchUpInside)
        rescanButton.addTarget(self, action: #selector(onRescanTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(onSaveTapped), for: .touchUpInside)

        addTestRow() // 최초 한 줄 생성
    }

    private func createPreviewCard() -> UIView {
        previewCard.translatesAutoresizingMaskIntoConstraints = false
        previewCard.backgroundColor = UIColor.systemGray6
        previewCard.layer.cornerRadius = 12
        previewCard.clipsToBounds = true

        let hStack = UIStackView()
        hStack.axis = .horizontal
        hStack.spacing = 12
        hStack.alignment = .center
        hStack.translatesAutoresizingMaskIntoConstraints = false

        previewImageView.image = previewImage ?? UIImage(systemName: "doc")
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.layer.cornerRadius = 8
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.widthAnchor.constraint(equalToConstant: 64).isActive = true
        previewImageView.heightAnchor.constraint(equalToConstant: 64).isActive = true

        previewTitleLabel.text = scanTitle
        previewTitleLabel.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        previewDateLabel.text = formattedTodayDate()
        previewDateLabel.font = UIFont.systemFont(ofSize: 12)
        previewDateLabel.textColor = .secondaryLabel

        let textStack = UIStackView(arrangedSubviews: [previewTitleLabel, previewDateLabel])
        textStack.axis = .vertical
        textStack.spacing = 4

        hStack.addArrangedSubview(previewImageView)
        hStack.addArrangedSubview(textStack)

        previewCard.addSubview(hStack)
        NSLayoutConstraint.activate([
            hStack.topAnchor.constraint(equalTo: previewCard.topAnchor, constant: 12),
            hStack.bottomAnchor.constraint(equalTo: previewCard.bottomAnchor, constant: -12),
            hStack.leadingAnchor.constraint(equalTo: previewCard.leadingAnchor, constant: 12),
            hStack.trailingAnchor.constraint(equalTo: previewCard.trailingAnchor, constant: -12)
        ])

        previewCard.addTarget(self, action: #selector(openPreviewFullScreen), for: .touchUpInside)

        return previewCard
    }

    private func formattedTodayDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: Date())
    }

    @objc private func addTestRow() {
        let testRow = TestRowView()
        testsContainerView.addArrangedSubview(testRow)
    }

    @objc private func onRescanTapped() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func onSaveTapped() {
        print("Saving...")
    }

    @objc private func openPreviewFullScreen() {
        guard let image = previewImage else { return }
        let vc = UIViewController()
        vc.view.backgroundColor = .black
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.frame = vc.view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        vc.view.addSubview(imageView)
        self.present(vc, animated: true, completion: nil)
    }
}

class TestRowView: UIStackView {

    let nameField = UITextField()
    let valueField = UITextField()
    let unitField = UITextField()

    init() {
        super.init(frame: .zero)
        axis = .horizontal
        spacing = 8
        distribution = .fill
        setup()
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        nameField.placeholder = "Test Name"
        nameField.borderStyle = .none
        nameField.font = UIFont.systemFont(ofSize: 15)
        nameField.setContentHuggingPriority(.defaultLow, for: .horizontal)

        valueField.placeholder = "Value"
        valueField.borderStyle = .roundedRect
        valueField.font = UIFont.systemFont(ofSize: 15)
        valueField.keyboardType = .decimalPad
        valueField.widthAnchor.constraint(equalToConstant: 60).isActive = true

        unitField.placeholder = "Unit"
        unitField.borderStyle = .roundedRect
        unitField.font = UIFont.systemFont(ofSize: 15)
        unitField.widthAnchor.constraint(equalToConstant: 70).isActive = true

        addArrangedSubview(nameField)
        addArrangedSubview(valueField)
        addArrangedSubview(unitField)
    }
}
