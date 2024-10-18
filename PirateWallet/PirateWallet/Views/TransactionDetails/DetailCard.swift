//
//  DetailCard.swift
//  PirateWallet
//
//  Created by Lokesh on 26/09/24.
//

import SwiftUI

struct DetailCard: View {
 
    var model: TransactionDetailModel
    var backgroundColor: Color = Color.init(red: 0.13, green: 0.14, blue: 0.15)
    var isFromWalletDetails = false
    var zecAmount: some View {
        let amount = model.zatoshi.decimalString()
        let text = ((model.zatoshi.amount > 0 && model.zatoshi.amount.asHumanReadableZecBalance() >= 0.001) ? "+" : "") + ((model.zatoshi.amount.asHumanReadableZecBalance() < 0.001 && model.zatoshi.amount > 0) ? "< 0.001" : amount)
        var color = Color.zARRRReceivedColor
        var opacity = Double(1)
        switch model.transaction {
        case .sent(let overview):
            color = Color.zARRRSentColor //success ? Color.zARRRSentColor : Color.zLightGray2
            opacity = 1
            
        case .received(let overview):
            color = Color.green //success ? Color.zARRRSentColor : Color.zLightGray2
            opacity = 1
        case .pending(let overview):
            color = Color.orange
        case .cleared(let overview):
            color = Color.white
        }
                
        return
            Text(text)
                .foregroundColor(color)
                .opacity(opacity)
            .scaledFont(size: Device.isLarge ? 16 : 12)
            
    }
    
    var body: some View {
        ZStack {
            HStack {
                Image.statusImage(for: model).resizable().frame(width: 20, height: 20, alignment: .center)

                VStack(alignment: .leading){
                    HStack {
//                        Text(model.title)
                        Text(model.created!.aNewFormattedDate)
                            .scaledFont(size: Device.isLarge ? 20 : 14)
                            .truncationMode(.tail)
                            .lineLimit(1)
                            .foregroundColor(.white)
                            .layoutPriority(0.5)

                    }
                    Text(String.transactionSubTitle(for: model))
                        .scaledFont(size: Device.isLarge ? 20 : 14)
                        .truncationMode(.tail)
                        .foregroundColor(.zARRRSubtitleColor)
                        .opacity(0.6)
                }
                .padding(.vertical, 8)
                Spacer()
                zecAmount
                    .padding(.trailing,10)
               
            }
            
        }.cornerRadius(5)
            .background(isFromWalletDetails ? Rectangle().fill(Color.init(red: 27.0/255.0, green: 28.0/255.0, blue: 29.0/255.0)) : Rectangle().fill((Color.clear)))
            .padding()
        
        
    }
    
}
