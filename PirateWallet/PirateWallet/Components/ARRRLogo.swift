//
//  ARRRLogo.swift
//  PirateWallet
//
//  Created by Lokesh on 13/09/24.
//


import UIKit
import SwiftUI

struct ARRRLogo<S: ShapeStyle>: View {

    var fillStyle: S
    
    var dimension = Device.isLarge ? 265.0 :  200.0
    
    init(fillStyle: S) {
        self.fillStyle = fillStyle
    }
    
    var body: some View {
        ZStack {
           
            VStack (alignment: .center) {
                Image("splashicon").resizable().padding(.horizontal)
                    .frame(width: dimension, height: dimension, alignment: .center)
                
            }
        }
    }
}
