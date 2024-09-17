//
//  ARRR+SwiftUI.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import Foundation
import SwiftUI

extension Text {
    static func subtitle(text: String) -> Text {
        Text(text)
        .foregroundColor(.zLightGray)
        .font(.footnote)
    }
}

extension ARRRButton {
    static func nukeButton() -> ARRRButton {
        ARRRButton(color: Color.red, fill: Color.clear, text: "NUKE WALLET".localized())
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}


struct SmallRecoveryWalletButtonView : View {
    
    @Binding var imageName: String
    @Binding var title: String

    
    
    var body: some View {
        ZStack {

            Image(imageName).resizable().frame(width: 175.0, height:84).padding(.top,5)
            
            Text(title).foregroundColor(Color.zARRRTextColorLightYellow)
                .frame(width: 175.0, height:84).padding(10)
                .cornerRadius(15)
                .multilineTextAlignment(.center)
        }.frame(width: 175.0, height:84)
    }
}

struct SmallBlueButtonView : View {
    
    @State var aTitle: String = ""
    
    var body: some View {
        ZStack {
            
            Image("bluebuttonbackground").resizable().frame(width: 175.0, height:84).padding(.top,5)
            
            Text(aTitle).foregroundColor(Color.black)
                .frame(width: 175.0, height:84)
                .cornerRadius(15)
                .multilineTextAlignment(.center)
        }.frame(width: 175.0, height:84)
        
    }
}


struct ForegroundPlaceholderModifier: ViewModifier {

var backgroundColor = Color(.systemBackground)

func body(content: Content) -> some View {
    content
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color.init(red: 29.0/255.0, green: 32.0/255.0, blue: 34.0/255.0))
                .softInnerShadow(RoundedRectangle(cornerRadius: 12), darkShadow: Color.init(red: 0.26, green: 0.27, blue: 0.3), lightShadow: Color.init(red: 0.06, green: 0.07, blue: 0.07), spread: 0.05, radius: 2))
    }
}

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}
