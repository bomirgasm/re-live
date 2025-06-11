//
//  ScanViewController.swift
//  re-live
//
//  Created by Suzie Kim on 6/5/25.
//

import UIKit
import VisionKit

class ScanViewController: UIViewController, VNDocumentCameraViewControllerDelegate {
    private let viewModel: ScanViewModel
    private let overlay = OCRCameraOverlayView()
    
    init(viewModel: ScanViewModel = ScanViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        presentDocumentCamera()

    }
    
    @objc private func presentDocumentCamera() {
        guard VNDocumentCameraViewController.isSupported else { return }
        let cameraViewController = VNDocumentCameraViewController()
        cameraViewController.delegate = self
        cameraViewController.view.addSubview(overlay)
        overlay.frame = cameraViewController.view.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        overlay.galleryButton.addTarget(self, action: #selector(openPhotoLibrary), for: .touchUpInside)
        present(cameraViewController, animated: true, completion: nil)
        
    }
    
    @objc private func openPhotoLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = false
        present(picker, animated: true, completion: nil)
    }
    
    func documentCameraViewControllerDidCancel(_ controller: VNDocumentCameraViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFailWithError error: Error) {
        controller.dismiss(animated: true) {
            self.viewModel.handleError(error)
        }
    }
    
    func documentCameraViewController(_ controller: VNDocumentCameraViewController, didFinishWith scan: VNDocumentCameraScan) {
        var images: [UIImage] = []
        for index in 0..<scan.pageCount {
            images.append(scan.imageOfPage(at: index))
        }
        
        controller.dismiss(animated: true) {
            self.viewModel.performOCR(on: images)
        }
    }
    
}

extension ScanViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true){
            if let image = info[.originalImage] as? UIImage {
                self.viewModel.performOCR(on: [image])
            }
        }
    }
}
