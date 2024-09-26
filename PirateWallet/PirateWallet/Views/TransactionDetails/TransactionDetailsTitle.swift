//
//  TransactionDetailsTitle.swift
//  PirateWallet
//
//  Created by Lokesh on 26/09/24.
//

import SwiftUI
import PirateLightClientKit

struct TransactionDetailsTitle: View {
    var availableZec: Double
    var transparentFundsAvailable: Bool = false
    
    var status: DetailModel.Status
    
    var available: some View {
        HStack{
           Text(format(zec: availableZec < 0 ? -availableZec : availableZec))
                .foregroundColor(.white)
                .scaledFont(size: Device.isLarge ? 32 : 22)
            Text(" \(arrr) ").padding(.top,2)
                .scaledFont(size: Device.isLarge ? 22 : 12)
                .foregroundColor(.zAmberGradient1)
        }
    }
    
    func format(zec: Double) -> String {
        NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: zec)) ?? "ERROR".localized() //TODO: handle this weird stuff
    }
    
    var aTitle: String {

        switch status {
        case .paid(let success):
            return success ? "You Sent".localized() : "Pending".localized()
        case .received:
            return "You Received".localized()
        }
    }
    
    var anImage: String {

        switch status {
        case .paid:
            return "wallet_history_sent"
        case .received:
            return "wallet_history_receive"
        }
    }
       
    var body: some View {
        VStack(alignment: .leading) {
            
            Text(aTitle)
                .foregroundColor(.zLightGray)
                .scaledFont(size: Device.isLarge ? 24 : 16)
                .padding(.leading,10)
            HStack{
                available.multilineTextAlignment(.leading)
                    .padding(.leading,10)
                Spacer()
                Text("")
                    .scaledFont(size: 12)
                    .foregroundColor(.gray).multilineTextAlignment(.trailing)
                
                Image(anImage).resizable().frame(width:40,height:40).multilineTextAlignment(.trailing)
            }
           
        }
    }
    
    var arrr: String {
        return "ARRR"
    }
}
