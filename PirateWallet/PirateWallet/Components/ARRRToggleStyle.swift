//
//  ARRRToggleStyle.swift
//  PirateWallet
//
//  Created by Lokesh on 25/10/24.
//


import SwiftUI

struct ARRRToggleStyle: ToggleStyle {
    @Binding var isHighlighted: Bool
    
    var activeColor = Color.zARRRReplySelectedColor
    var inactiveColor = Color.zGray2
    func makeBody(configuration: Configuration) -> some View {

        Button(action: {
            configuration.isOn.toggle()
        }) {
            HStack {
                ZStack {
                    Rectangle()
                        .stroke(inactiveColor, lineWidth: isHighlighted ? 0 : 0.5)
                        .background(isHighlighted ? activeColor : Color.clear)
                    Image("checkmark")
                        .colorMultiply(.black)
                        .accessibility(label: Text("checkmark"))
                        .opacity(isHighlighted ? 1 : 0)
                    
                }
                .frame(width: 16, height: 16)
                
                configuration.label
                    .font(.footnote)
                    .foregroundColor(.white)
            }
        }
    }
}

