//
//  QRCodeContainer.swift
//  PirateWallet
//
//  Created by Lokesh on 25/10/24.
//

import SwiftUI

struct QRCodeContainer: View {
    var qrImage: Image
    var badge: Image
    var body: some View {
        ZStack {
            qrImage
                .resizable()
                .aspectRatio(contentMode: .fit)
            badge
            .resizable()
            .frame(width: 22, height: 22)
        }
    }
}

struct QRCodeContainer_Previews: PreviewProvider {
    static var previews: some View {
        
        ZStack {
            ARRRBackground()
            QRCodeContainer(qrImage: Image("QrCode"),
                            badge: Image("skullcoin"))
            .frame(width: 285, height: 285)
            
        }
    }
}
