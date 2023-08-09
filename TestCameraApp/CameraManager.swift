//
//  CameraManager.swift
//  TestCameraApp
//
//  Created by Vladislav Stolyarov on 06.08.2023.
//

import AVFoundation
import UIKit

final class CameraManager: NSObject {
    
    // MARK: Properties
    private let captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    private var currentDevice: AVCaptureDevice?
    private var photoOutput = AVCapturePhotoOutput()
    private var videoOutput = AVCaptureMovieFileOutput()
    
    
    // MARK: Initialization
    override init() {
        super.init()
        setupCaptureSession()
    }
    
    // MARK: Setup before initialization
    private func setupCaptureSession() {
        captureSession.sessionPreset = .high
        
        // Configure video input
        if let videoDevice = AVCaptureDevice.default(for: .video) {
            currentDevice = videoDevice
            do {
                let input = try AVCaptureDeviceInput(device: videoDevice)
                if captureSession.canAddInput(input) {
                    captureSession.addInput(input)
                }
            } catch {
                print("Error setting up camera input: \(error.localizedDescription)")
            }
        }
        
        // Configure audio input
        if let audioDevice = AVCaptureDevice.default(for: .audio) {
            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if captureSession.canAddInput(audioInput) {
                    captureSession.addInput(audioInput)
                }
            } catch {
                print("Error setting up audio input: \(error.localizedDescription)")
            }
        }
        
        // Configure audio recording
        do {
            try AVAudioSession.sharedInstance().setCategory(.record, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Error setting up audio session: \(error.localizedDescription)")
        }
        
        // Configure capture output (photo or video)
        if captureSession.canAddOutput(photoOutput) {
            captureSession.addOutput(photoOutput)
        }
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        // Configure video preview layer
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = .resizeAspectFill
        
        // Start the camera session to display the live preview
        DispatchQueue.global(qos: .userInitiated).async {
            self.startSession()
        }
    }
    
    
    func startSession() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    
    // MARK: Toggling Cameras
    static func device(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position)
    }
    
    
    func toggleCameraPosition() {
        guard let currentDevice = currentDevice else { return }
        
        captureSession.beginConfiguration()
        captureSession.removeInput(captureSession.inputs.first!)
        
        let newDevice: AVCaptureDevice
        if currentDevice.position == .back {
            newDevice = CameraManager.device(position: .front)!
        } else {
            newDevice = CameraManager.device(position: .back)!
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: newDevice)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                self.currentDevice = newDevice
            }
        } catch {
            print("Error switching camera: \(error.localizedDescription)")
        }
        
        captureSession.commitConfiguration()
    }
    
    
    
    // MARK: Capture Photo/Video
    func capturePhoto(completion: @escaping (Bool) -> Void) {
        guard photoOutput.connection(with: .video) != nil else {
            completion(false)
            return
        }

        photoOutput.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        completion(true)
    }
    
    func startVideoRecording() {
        // Start video recording
        let outputPath = NSTemporaryDirectory() + "video.mp4"
        let outputURL = URL(fileURLWithPath: outputPath)
        videoOutput.startRecording(to: outputURL, recordingDelegate: self)
    }

    func stopVideoRecording(completion: @escaping (Bool) -> Void) {
        videoOutput.stopRecording()
        completion(true)
    }
    
}


    // MARK: Confronting to AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate
extension CameraManager: AVCapturePhotoCaptureDelegate, AVCaptureFileOutputRecordingDelegate {
    
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let error = error {
            print("Error recording video: \(error.localizedDescription)")
            return
        }
        
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(outputFileURL.path) {
            UISaveVideoAtPathToSavedPhotosAlbum(outputFileURL.path, self, #selector(video(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }

    @objc func video(_ videoPath: String, didFinishSavingWithError error: NSError?, contextInfo info: AnyObject) {
        if let error = error {
            print("Error saving video: \(error.localizedDescription)")
            return
        }
    }

    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if error != nil {
            return
        }

        if let imageData = photo.fileDataRepresentation() {
            if let capturedImage = UIImage(data: imageData) {
                UIImageWriteToSavedPhotosAlbum(capturedImage, nil, nil, nil)
            }
        }
    }
}
