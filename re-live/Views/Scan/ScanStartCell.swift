//
//  ScanStartCell.swift
//  re-live
//
//  Created by Suzie Kim on 6/11/25.
//

import UIKit

final class ScanStartCell: UICollectionViewCell {
    static let identifier = "ScanStartCell"
    
    var onScanTapped: (() -> Void)?
    var onGalleryTapped: (() -> Void)?
    
    private let scanButton = UIButton(type: .system)
    private let galleryButton = UIButton(type: .system)
    private let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        scanButton.setTitle("Scan New Record", for: .normal)
        scanButton.backgroundColor = .systemBlue
        scanButton.setTitleColor(.white, for: .normal)
        scanButton.layer.cornerRadius = 8
        scanButton.addTarget(self, action: #selector(didTapScan), for: .touchUpInside)
        
        galleryButton.setTitle("Bring from Photos", for: .normal)
        galleryButton.backgroundColor = .systemGreen
        galleryButton.setTitleColor(.white, for: .normal)
        galleryButton.layer.cornerRadius = 8
        galleryButton.addTarget(self, action: #selector(didTapGallery), for: .touchUpInside)
        
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.addArrangedSubview(scanButton)
        stackView.addArrangedSubview(galleryButton)
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            scanButton.heightAnchor.constraint(equalToConstant: 44),
            galleryButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc private func didTapScan() {
        onScanTapped?()
    }
    
    @objc private func didTapGallery() {
        onGalleryTapped?()
    }
}
