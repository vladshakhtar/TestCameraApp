//
//  ViewController.swift
//  TestCameraApp
//
//  Created by Vladislav Stolyarov on 06.08.2023.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    
    // MARK: IBOutlets
    @IBOutlet private weak var cameraView: UIView!
    
    
    @IBOutlet private weak var captureMediaButton: UIButton!
    
    
    @IBOutlet private weak var switchCameraButton: UIButton!
    
    
    @IBOutlet private weak var switchMediaButton: UIButton!
    
    
    //MARK: ViewModel
    private var viewModel: CameraViewModel!
    
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        viewModel = CameraViewModel()
        setupCameraPreview()
        captureMediaButton.layer.cornerRadius = 20
    }
    
    func setupCameraPreview() {
        if let previewLayer = viewModel.videoPreviewLayer {
            previewLayer.frame = cameraView.bounds
            cameraView.layer.addSublayer(previewLayer)
        }
    }
    
    
    //MARK: IBActions
    
    @IBAction func captureMediaButtonTapped(_ sender: Any) {
        if viewModel.getCurrentMediaType() == .photo {
            viewModel.capturePhoto { [weak self] success in
                if success {
                    self?.showAlert(title: "Success", message: "Photo successfully captured and saved.")
                } else {
                    self?.showAlert(title: "Error", message: "Failed to capture and save photo.")
                }
            }
        } else {
            if !viewModel.isRecordingVideo {
                // Start video recording
                viewModel.startVideoRecording()
                // Update UI: Change button image to a square, hide other buttons
                DispatchQueue.main.async {
                    self.captureMediaButton.setImage(UIImage(systemName: "square"), for: .normal)
                    self.switchCameraButton.isHidden = true
                    self.switchMediaButton.isHidden = true
                }
            } else {
                // Stop video recording
                viewModel.stopVideoRecording { [weak self] success in
                    if success {
                        self?.showAlert(title: "Success", message: "Video successfully recorded and saved.")
                    } else {
                        self?.showAlert(title: "Error", message: "Failed to record and save video.")
                    }
                }
                // Update UI: Change button image back to a circle, show other buttons
                DispatchQueue.main.async {
                    self.captureMediaButton.setImage(UIImage(systemName: "circle"), for: .normal)
                    self.switchCameraButton.isHidden = false
                    self.switchMediaButton.isHidden = false
                }
            }
            // Toggle the recording state
            viewModel.isRecordingVideo.toggle()
        }
    }
    
    
    @IBAction func switchCameraButtonTapped(_ sender: Any) {
        viewModel.toggleCameraPosition()
    }
    
    
    
    @IBAction func switchMediaButtonTapped(_ sender: Any) {
        if viewModel.getCurrentMediaType() == .photo {
            viewModel.setCurrentMediaType(.video)
            // Update UI: Change button label text to "Video"
            DispatchQueue.main.async {
                self.switchMediaButton.setTitle("Video", for: .normal)
            }
        } else {
            viewModel.setCurrentMediaType(.photo)
            // Update UI: Change button label text to "Photo"
            DispatchQueue.main.async {
                self.switchMediaButton.setTitle("Photo", for: .normal)
            }
        }
    }
    
    
    // MARK: ALertController
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}

