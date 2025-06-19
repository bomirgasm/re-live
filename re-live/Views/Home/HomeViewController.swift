//
//  HomeViewController.swift
//  re-live
//
//  Created by Suzie Kim on 6/5/25.
//

import Foundation
import UIKit
import PhotosUI
import VisionKit

// MARK: - Section Enum

enum HomeSection: Int, CaseIterable {
    case greeting
    case healthStats
    case scanStart
    case recentRecords
}

// MARK: - HomeViewController

class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView!
    private let ocrService = OCRService.shared
    
    private func showEditView(with ocrText: String, previewImage: [UIImage]) {
        let ocrResult = OCRResult(text: ocrText)
        let editVC = EditResultViewController()
        editVC.ocrResult = ocrResult
        editVC.previewImage = previewImage
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        view.backgroundColor = .systemBackground
    }
    
    private func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 16)
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 8
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        
        collectionView.register(GreetingCell.self, forCellWithReuseIdentifier: GreetingCell.identifier)
        collectionView.register(HealthStatCardCell.self, forCellWithReuseIdentifier: HealthStatCardCell.identifier)
        collectionView.register(ScanStartCell.self, forCellWithReuseIdentifier: ScanStartCell.identifier)
        collectionView.register(RecentRecordCell.self, forCellWithReuseIdentifier: RecentRecordCell.identifier)
        
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
}

// MARK: - UICollectionViewDataSource

extension HomeViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return HomeSection.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch HomeSection(rawValue: section)! {
        case .greeting: return 1
        case .healthStats: return 2
        case .scanStart: return 1
        case .recentRecords: return 3
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch HomeSection(rawValue: indexPath.section)! {
        case .greeting:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GreetingCell.identifier, for: indexPath) as! GreetingCell
            cell.configure(greeting: "Welcome back, Suzie", dateText: "Thursday, May 29, 2025")
            return cell
            
        case .healthStats:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HealthStatCardCell.identifier, for: indexPath) as! HealthStatCardCell
            if indexPath.item == 0 {
                cell.configure(
                    title: "Blood Pressure",
                    value: "120/80",
                    unit: "mmHg",
                    icon: "heart.fill",
                    status: "Normal",
                    statusColor: .systemGreen)
            } else {
                cell.configure(title: "Cholesterol", value: "210", unit: "mg/dL", icon: "drop.fill", status: "Slightly high", statusColor: .systemOrange)
            }
            return cell
            
        case .scanStart:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ScanStartCell.identifier, for: indexPath) as! ScanStartCell
            cell.onScanTapped = { [weak self] in
                self?.presentDocumentCamera()
            }
            cell.onGalleryTapped = { [weak self] in
                self?.presentPhotoPicker()
            }
            return cell
            
        case .recentRecords:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecentRecordCell.identifier, for: indexPath) as! RecentRecordCell
            if indexPath.item == 0 {
                cell.configure(title: "Annual Check-up", date: "May 15, 2025")
            } else if indexPath.item == 1 {
                cell.configure(title: "Blood Test", date: "April 22, 2025")
            } else {
                cell.configure(title: "BP Check", date: "April 10, 2025")
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HomeViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.bounds.width - 32
        switch HomeSection(rawValue: indexPath.section)! {
        case .greeting:
            return CGSize(width: width, height: 72)
        case .healthStats:
            let interItemSpacing: CGFloat = 8
            let halfWidth = (width - interItemSpacing) / 2
            return CGSize(width: halfWidth, height: 120)
        case .scanStart:
            return CGSize(width: width, height: 120)
        case .recentRecords:
            return CGSize(width: width, height: 100)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 16
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 8
    }
}

extension HomeViewController: VNDocumentCameraViewControllerDelegate, PHPickerViewControllerDelegate, UINavigationControllerDelegate {
    
    private func presentDocumentCamera() {
        guard VNDocumentCameraViewController.isSupported else {
            print("Document camera not supported")
            return
        }
        let cameraVC = VNDocumentCameraViewController()
        cameraVC.delegate = self
        present(cameraVC, animated: true, completion: nil)
    }
    
    private func presentPhotoPicker() {
        var configuration = PHPickerConfiguration()
        configuration.selectionLimit = 0 // 0 = 무제한 선택
        configuration.filter = .images
        
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    // MARK: - VNDocumentCameraViewControllerDelegate
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true) {
            print("Camera scan failed: \(error)")
        }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        controller.dismiss(animated: true) {
            print("Scanned \(scan.pageCount) pages.")
            guard scan.pageCount > 0 else { return }
            
            var images: [UIImage] = []
            for i in 0..<scan.pageCount {
                images.append(scan.imageOfPage(at: i))
            }
            
            var ocrTexts: [String] = []
            let dispatchGroup = DispatchGroup()
            
            for (index, image) in images.enumerated() {
                dispatchGroup.enter()
                self.ocrService.recognizeText(in: image) { result in
                    switch result {
                    case .success(let ocr):
                        ocrTexts.append(ocr.text)
                        print("✅ OCR result (page \(index + 1)):\n\(ocr.text)\n")
                    case .failure(let error):
                        print("OCR failed: \(error)")
                        print("❌ OCR failed on page \(index + 1): \(error)")
                    }
                    dispatchGroup.leave()
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                let combinedText = ocrTexts.joined(separator: "\n\n--- Page Break --- \n\n")
                self.showEditView(with: combinedText, previewImage: images)
            }
        }
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        var images: [UIImage] = []
        let dispatchGroup = DispatchGroup()
        
        for result in results {
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                dispatchGroup.enter()
                result.itemProvider.loadObject(ofClass: UIImage.self) { (object, error) in
                    defer { dispatchGroup.leave() }
                    
                    if let image = object as? UIImage {
                        images.append(image)
                    } else {
                        print("Failed to load image: \(String(describing: error))")
                    }
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            guard !images.isEmpty else {
                print("No images loaded from gallery")
                return
            }
            
            print("Loaded \(images.count) images from gallery")
            
            var ocrTexts = Array<String?>(repeating: nil, count: images.count)
            let ocrGroup = DispatchGroup()
            
            for (index, image) in images.enumerated() {
                ocrGroup.enter()
                self.ocrService.recognizeText(in: image) { result in
                    switch result {
                    case .success(let ocr):
                        ocrTexts[index] = ocr.text
                        print("OCR result (gallery image \(index + 1)):\n\(ocr.text)")
                    case .failure(let error):
                        print("OCR failed (gallery image \(index + 1)): \(error)")
                    }
                    ocrGroup.leave()
                }
            }
            
            ocrGroup.notify(queue: .main) {
                let combinedText = ocrTexts.compactMap { $0 }.joined(separator: "\n\n--- Page Break ---\n\n")
                self.showEditView(with: combinedText, previewImage: images)
            }
        }
    }
}
