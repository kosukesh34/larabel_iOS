import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String
    @Binding var isScanning: Bool

    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    class Coordinator: NSObject, ScannerViewControllerDelegate {
        let parent: BarcodeScannerView

        init(parent: BarcodeScannerView) {
            self.parent = parent
        }

        func didFind(barcode: String) {
            parent.scannedCode = barcode
            parent.isScanning = false
        }
    }
}


import UIKit
import AVFoundation

protocol ScannerViewControllerDelegate: AnyObject {
    func didFind(barcode: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    weak var delegate: ScannerViewControllerDelegate?

    private let captureSession = AVCaptureSession()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }

        if let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
           captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }

        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean13, .qr, .code128, .ean8, .upce, .pdf417]
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)

        captureSession.startRunning()
    }

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let code = metadataObject.stringValue {
            captureSession.stopRunning()
            delegate?.didFind(barcode: code)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
}
