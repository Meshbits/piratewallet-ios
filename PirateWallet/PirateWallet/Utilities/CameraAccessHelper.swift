//
//  CameraAccessHelper.swift
//  PirateWallet
//
//  Created by Lokesh on 06/12/24.
//

import Foundation
import AVFoundation

class CameraAccessHelper {
    
    enum Status {
        case authorized
        case unauthorized
        case unavailable
        case undetermined
    }
    
    static var authorizationStatus: CameraAccessHelper.Status {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)

        switch cameraAuthorizationStatus {
        case .authorized:
            return Status.authorized
        case .denied:
            return Status.unauthorized
        case .restricted:
            return .unavailable
        case .notDetermined:
            return Status.undetermined
        @unknown default:
            return .unavailable
        }
    }
}
