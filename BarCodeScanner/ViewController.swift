//
//  ViewController.swift
//  BarCodeScanner
//
//  Created by Mahendra Naidu on 11/27/20.
//

import UIKit


// MARK: - Main ViewController

class ViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    /// Button to initiate barcode scanning
    @IBOutlet weak var scanBarButton: UIButton!
    
    /// Text field to display the scanned result
    @IBOutlet weak var scanTextField: UITextField!
    
    // MARK: - Properties
    
    /// Instance of the scanner view controller
    let scannerViewController = ScannerViewController()
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the background color of the view
        view.backgroundColor = UIColor.systemBlue
        
        // Setup UI styling and logic
        updateUI()
        
        // Set the delegate to receive scanned text
        scannerViewController.delegate = self
    }
}

// MARK: - ScannerViewDelegate

extension ViewController: ScannerViewDelegate {
    
    /// This method gets called when barcode is successfully scanned
    func didFindScannedText(text: String) {
        scanTextField.text = text
    }
}

// MARK: - UI Setup

extension ViewController {
    
    /// Setup and style the UI components
    private func updateUI() {
        // Configure the scan button
        scanBarButton.backgroundColor = UIColor.systemYellow
        scanBarButton.setTitle("Scan Bar Code", for: .normal)
        scanBarButton.setTitleColor(UIColor.white, for: .normal)
        scanBarButton.titleLabel!.font = UIFont(name: "AppleSDGothicNeo-Thin", size: 25)
        scanBarButton.layer.cornerRadius = 5
        
        // Add tap action to the button
        scanBarButton.addTarget(self, action: #selector(scanBarTapped), for: .touchUpInside)
        
        // Configure the text field
        scanTextField.text = "Default"
        scanTextField.textAlignment = .center
        scanTextField.textColor = UIColor.white
        scanTextField.font = UIFont(name: "AppleSDGothicNeo-Bold", size: 25)
    }
    
    /// Action triggered when the scan button is tapped
    @objc func scanBarTapped() {
        // Navigate to the scanner view controller
        self.navigationController?.pushViewController(scannerViewController, animated: true)
    }
}
