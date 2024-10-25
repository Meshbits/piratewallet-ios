//
//  AddressFragmentWithoutNumber.swift
//  PirateWallet
//
//  Created by Lokesh on 25/10/24.
//


import SwiftUI

struct AddressFragmentWithoutNumber: View {
    
    var word: String
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                HStack(alignment: .center, spacing: 4) {
                    
                    Text(self.word)
                        .foregroundColor(.gray)
                        .scaledFont(size: Device.isLarge ? 15 : 12)
                }
                .padding(.trailing, 4)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                
                
            }
        }
    }
}


//struct AddressFragmentWithoutNumber_Previews: PreviewProvider {
//    static var previews: some View {
//        AddressFragmentWithoutNumber()
//    }
//}
