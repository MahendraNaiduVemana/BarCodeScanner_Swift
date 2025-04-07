//
//  ScannerViewController.swift
//  BarCodeScanner
//
//  Created by Mahendra Naidu on 11/27/20.
//

import UIKit
import AVFoundation

// MARK: - Delegate Protocol for Scanner Results
@objc protocol ScannerViewDelegate: AnyObject {
    // Callback method to return scanned text
    @objc func didFindScannedText(text: String)
}

class ScannerViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Properties
    
    /// AVCaptureSession to manage input and output of capture
    var captureSession: AVCaptureSession!
    
    /// Layer to show camera preview
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    /// Delegate to handle scanned result
    @objc public weak var delegate: ScannerViewDelegate?

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background color
        view.backgroundColor = UIColor.black
        
        // Initialize the capture session
        captureSession = AVCaptureSession()
        
        // Get the device's camera
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }

        do {
            // Create input from camera
            let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            
            // Add input to capture session
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            } else {
                failed() // Show error alert if input cannot be added
                return
            }
        } catch {
            print("Error creating video input: \(error)")
            return
        }
        
        // Setup metadata output (for barcodes)
        let metadataOutput = AVCaptureMetadataOutput()
        
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            // Set delegate to handle found metadata
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            // Set the types of codes to scan
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417]
        } else {
            failed() // Show error alert if output cannot be added
            return
        }
        
        // Configure preview layer to show camera feed
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        // Start the camera session
        captureSession.startRunning()
    }

    // MARK: - View Appearance

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Restart session if not already running
        if captureSession?.isRunning == false {
            captureSession.startRunning()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop session to save battery
        if captureSession?.isRunning == true {
            captureSession.stopRunning()
        }
    }

    // MARK: - Handle Scanning Failure

    func failed() {
        // Show alert if scanning is not supported
        let alert = UIAlertController(
            title: "Scanning not supported",
            message: "Your device does not support scanning a code from an item. Please use a device with a camera.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
        captureSession = nil
    }

    // MARK: - AVCaptureMetadataOutput Delegate

    func metadataOutput(_ output: AVCaptureMetadataOutput,
                        didOutput metadataObjects: [AVMetadataObject],
                        from connection: AVCaptureConnection) {
        // Stop the session once a code is found
        captureSession.stopRunning()

        // Read and handle scanned value
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = metadataObject.stringValue {
            // Vibrate to give feedback
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

        // Dismiss scanner screen
        dismiss(animated: true)
    }

    // MARK: - Handle Found Code

    func found(code: String) {
        print("Scanned Code: \(code)")
        delegate?.didFindScannedText(text: code)
        navigationController?.popViewController(animated: true)
    }

    // MARK: - UI Settings

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
