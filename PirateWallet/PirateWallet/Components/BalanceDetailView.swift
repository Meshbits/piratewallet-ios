//
//  BalanceDetailView.swift
//  PirateWallet
//
//  Created by Lokesh on 24/09/24.
//

import SwiftUI
import PirateLightClientKit

struct BalanceDetailView: View {
    var availableZec: Double
    var transparentFundsAvailable: Bool = false
    var status: BalanceStatus
    
    var available: some View {
        HStack{
            Text(format(zec: availableZec))
                .foregroundColor(.white)
                .scaledFont(size: Device.isLarge ? 30 : 20)
                
            Text(" \(zec) ")
                .scaledFont(size: Device.isLarge ? 20 : 12)
                .foregroundColor(.zAmberGradient1)
        }
        .padding(.leading,10)
    }
    
    func format(zec: Double) -> String {
        NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: zec)) ?? "ERROR".localized() //TODO: handle this weird stuff
    }
    var includeCaption: Bool {
        switch status {
        case .available(_):
            return false
        default:
            return true
        }
    }
    var caption: some View {
        switch status {
        case .expecting(let zec):
            return  Text("(\("expecting".localized()) ")
                           .font(.body)
                           .foregroundColor(Color.zLightGray) +
            Text("+" + format(zec: zec))
                           .font(.body)
                .foregroundColor(.white)
            + Text(" \(zec))")
                .font(.body)
                .foregroundColor(Color.zLightGray)
        
        case .waiting(let change):
            return  Text("(\("expecting".localized()) ")
                                      .font(.body)
                                    .foregroundColor(Color.zLightGray) +
                       Text("+" + format(zec: change))
                                      .font(.body)
                           .foregroundColor(.white)
                       + Text(" \(zec))")
                           .font(.body)
                           .foregroundColor(Color.zLightGray)
            default:
                return Text("")
        }
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text("Balance".localized())
                .foregroundColor(.zLightGray)
                .scaledFont(size: Device.isLarge ? 18 : 14)
                .padding(.leading,20)
            HStack{
                available.multilineTextAlignment(.leading)
                    .padding(.leading,10)
                Spacer()
                Text("")
                    .scaledFont(size: 12)
                    .foregroundColor(.gray).multilineTextAlignment(.trailing)
            }
            if includeCaption {
                caption
            }
        }
    }
    
    var zec: String {
        return "ARRR"
    }
}

struct BalanceDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ARRRBackground()
            VStack(alignment: .center, spacing: 50) {
                BalanceDetailView(availableZec: 2.0011,status: .available(showCaption: true))
                BalanceDetailView(availableZec: 0.0011,status: .expecting(arrr: 2))
                BalanceDetailView(availableZec: 12.2,status: .waiting(change: 5.3111112))
            }
        }
    }
}

