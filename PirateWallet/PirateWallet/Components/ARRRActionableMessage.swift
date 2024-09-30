//
//  ARRRActionableMessage.swift
//  PirateWallet
//
//  Created by Lokesh on 30/09/24.
//


import SwiftUI

struct ARRRActionableMessage: View {
    var message: String
    var actionText: String? = nil
    var action: (() -> Void)? = nil
    let cornerRadius: CGFloat =  5
    
    var actionView: some View {
        if let action = self.action, let text = actionText {
            return AnyView(
                Button(action: action) {
                    Text(text)
                        .foregroundColor(Color.zAmberGradient2)
                }
            )
        } else {
            return AnyView (
                EmptyView()
            )
        }
    }
    var body: some View {
        
        HStack {
            Text(message)
            .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .scaledFont(size: 19)
            actionView
                
        }
        .padding()
        .cornerRadius(cornerRadius)
//        .background(Color.zDarkGray2)
//        .overlay(
//            RoundedRectangle(cornerRadius: cornerRadius)
//                .stroke(Color.zGray, lineWidth: 1)
//        )
    }
}

struct ARRRActionableMessage_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ARRRBackground()
            ARRRActionableMessage(message: "ARRR address in buffer!", actionText: "Paste", action: {})
            .padding()
            
        }
    }
}
