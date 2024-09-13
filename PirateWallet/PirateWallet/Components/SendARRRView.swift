//
//  SendARRRView.swift
//  PirateWallet
//
//  Created by Lokesh on 13/09/24.
//


import SwiftUI

struct SendARRRView: View {
    
    @Binding var zatoshi: String
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 0) {
  
            Text("$\(self.$zatoshi.wrappedValue)")
            .lineLimit(1)
            .scaleEffect(Device.isLarge ? 1 : 0.85)
            .foregroundColor(.white)
            .font(
                .custom("Zboto", size: Device.isLarge ? 72 : 52)
                
            )
        }
    }
}

struct SendZecView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ARRRBackground()
            SendARRRView(zatoshi: .constant("12.345"))
        }
    }
}

enum PhoneScreen {
    case small, large
}

struct Device {
    static var isLarge: Bool {
        return screen == .large
    }
    
    private static var screen: PhoneScreen {
        switch UIScreen.main.nativeBounds.height {
        case 1136...1334:
            return .small
        default:
            return .large
        }
    }
}
