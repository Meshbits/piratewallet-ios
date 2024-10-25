//
//  AddressFragment.swift
//  PirateWallet
//
//  Created by Lokesh on 25/10/24.
//


import SwiftUI

struct AddressFragment: View {
    
    var number: Int
    var word: String
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                
                HStack(alignment: .center, spacing: 4) {
                    
                    Text(String(self.number))
                        .baselineOffset(geometry.size.height/8)
                        .scaledFont(size: 12)
                        .foregroundColor(Color.zYellow)
                        .frame(minWidth: geometry.size.width*0.18, alignment: .trailing)
                        
                    
                    Text(self.word)
                        .foregroundColor(.gray)
                        .scaledFont(size: 18)
                        
                   
                }
                .padding(.trailing, 4)
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .leading)
                
                
            }
        }
    }
}

struct AddressFragment_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ARRRBackground()
            VStack {
                AddressFragment(number: 1, word: "1234")
                    .frame(width: 100, height: 30, alignment: .leading)
                AddressFragment(number: 23, word: "12345")
                    .frame(width: 100, height: 30)
                AddressFragment(number: 23, word: "123456")
                    .frame(width: 100, height: 30)
                AddressFragment(number: 23, word: "1234567")
                .frame(width: 100, height: 30)
                AddressFragment(number: 23, word: "12345678")
                .frame(width: 100, height: 30)
            }
            
        }
    }
}
