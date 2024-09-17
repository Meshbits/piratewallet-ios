//
//  DeviceFeedbackHelper.swift
//  PirateWallet
//
//  Created by Lokesh on 17/09/24.
//


import Foundation

import AVFoundation
class DeviceFeedbackHelper {
    
    static func vibrate() {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    static func longVibrate(){
        AudioServicesPlaySystemSoundWithCompletion(kSystemSoundID_Vibrate) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
}
