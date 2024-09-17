//
//  ARRRCloseButon.swift
//  PirateWallet
//
//  Created by Lokesh on 17/09/24.
//

import SwiftUI
import Neumorphic

struct ARRRCloseButton: View {
    var action: () -> Void
    
    var body: some View {
        
        ZStack {
//            Image("passcodenumericbg")

            Button(action: {
                self.action()
            }) {
                VStack(alignment: .leading) {
                    ZStack{
                        Image("closebutton").resizable().frame(width: Device.isLarge ? 70 : 40, height: Device.isLarge ? 70 : 40)
                    }
                }
            }
        }.padding(2)
        
       
    }
}
