//
//  CameraViewModel.swift
//  TestCameraApp
//
//  Created by Vladislav Stolyarov on 06.08.2023.
//

import Foundation
import AVFoundation

enum MediaType {
    case photo, video
}

final class CameraViewModel {
    
    // MARK: Properties
    private let cameraManager = CameraManager()
    
    var videoPreviewLayer: AVCaptureVideoPreviewLayer? {
        return cameraManager.videoPreviewLayer
    }
    
    private var mediaType : MediaType = .photo
    
    var isRecordingVideo: Bool = false 
    
    
    
    
    // MARK: Main Functions
    func capturePhoto(completion: @escaping (Bool) -> Void) {
        cameraManager.capturePhoto(completion: completion)
    }
    
    func startVideoRecording() {
        cameraManager.startVideoRecording()
    }
    
    func stopVideoRecording(completion: @escaping (Bool) -> Void) {
        cameraManager.stopVideoRecording { success in
            if success {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func toggleCameraPosition() {
        cameraManager.toggleCameraPosition()
    }
    
    
    
    
    // MARK: Other helpful functions
    private func toggleCameraMode() {
        if mediaType == .photo {
            mediaType = .video
        } else {
            mediaType = .photo
        }
    }
    
    func getCurrentMediaType() -> MediaType {
        return mediaType
    }
    
    func setCurrentMediaType(_ type : MediaType) {
        mediaType = type
    }
}

