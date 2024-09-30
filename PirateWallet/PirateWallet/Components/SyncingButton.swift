//
//  SyncingButton.swift
//  PirateWallet
//
//  Created by Lokesh on 30/09/24.
//

import Foundation
import SwiftUI
import Lottie

struct SyncingButton<Content: View>: View {
    
    var label: Content
    var animationType: LottieAnimation.AnimationType
    init(animationType: LottieAnimation.AnimationType, @ViewBuilder content: () -> Content) {
        self.label = content()
        self.animationType = animationType
    }
    
    var body: some View {
        ZStack {
            LottieAnimation(isPlaying: true, filename: "lottie_button_loading_new", animationType: self.animationType)
            label
        }
    }
}
