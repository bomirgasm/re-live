//
//  OCRCameraOverlayView.swift
//  re-live
//
//  Created by Suzie Kim on 6/5/25.
//

import UIKit

final class OCRCameraOverlayView: UIView {
    private let frameView = UIView()
    private let scanLine = UIView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let borderLayer = CAShapeLayer()
    public let galleryButton = UIButton()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = false
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }

    private func setupView() {
        backgroundColor = .clear

        frameView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(frameView)
        frameView.layer.addSublayer(borderLayer)

        scanLine.backgroundColor = UIColor.systemBlue
        scanLine.translatesAutoresizingMaskIntoConstraints = false
        frameView.addSubview(scanLine)

        titleLabel.text = "Position your medical document"
        titleLabel.textColor = .white
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(titleLabel)

        subtitleLabel.text = "Make sure all text is visible and well-lit"
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        subtitleLabel.font = .systemFont(ofSize: 14)
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subtitleLabel)
        
        galleryButton.translatesAutoresizingMaskIntoConstraints = false
        galleryButton.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        galleryButton.tintColor = .white
        addSubview(galleryButton)

        NSLayoutConstraint.activate([
            frameView.centerXAnchor.constraint(equalTo: centerXAnchor),
            frameView.centerYAnchor.constraint(equalTo: centerYAnchor),
            frameView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            frameView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.4),

            scanLine.leadingAnchor.constraint(equalTo: frameView.leadingAnchor),
            scanLine.trailingAnchor.constraint(equalTo: frameView.trailingAnchor),
            scanLine.topAnchor.constraint(equalTo: frameView.topAnchor),
            scanLine.heightAnchor.constraint(equalToConstant: 4),

            titleLabel.topAnchor.constraint(equalTo: frameView.bottomAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            subtitleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            galleryButton.widthAnchor.constraint(equalToConstant: 64),
            galleryButton.heightAnchor.constraint(equalToConstant: 64),
            galleryButton.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            galleryButton.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20)

            
        ])
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        borderLayer.frame = frameView.bounds
        borderLayer.path = UIBezierPath(roundedRect: frameView.bounds, cornerRadius: 12).cgPath
        borderLayer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.7).cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.lineWidth = 2
        borderLayer.lineDashPattern = [6, 6]
        startScanAnimation()
    }

    private func startScanAnimation() {
        scanLine.layer.removeAllAnimations()
        let animation = CABasicAnimation(keyPath: "position.y")
        animation.fromValue = 0
        animation.toValue = frameView.bounds.height
        animation.duration = 2.0
        animation.repeatCount = .infinity
        scanLine.layer.add(animation, forKey: "scan")
    }
    
    func setGalleryButtonTarget(_ target: Any?, action: Selector, for event: UIControl.Event) {
        galleryButton.addTarget(target, action: action, for: event)
    }
    
}
