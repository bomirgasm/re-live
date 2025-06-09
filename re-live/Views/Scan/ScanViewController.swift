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
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentDocumentCamera()
    }

    private func presentDocumentCamera() {
        guard VNDocumentCameraViewController.isSupported else { return }
        let cameraViewController = VNDocumentCameraViewController()
        cameraViewController.delegate = self
        cameraViewController.view.addSubview(overlay)
        overlay.frame = cameraViewController.view.bounds
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        present(cameraViewController, animated: true, completion: nil)
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
