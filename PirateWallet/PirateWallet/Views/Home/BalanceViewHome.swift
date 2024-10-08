//
//  BalanceViewHome.swift
//  PirateWallet
//
//  Created by Lokesh on 29/09/24.
//

import SwiftUI
import PirateLightClientKit

struct BalanceViewHome: View {
    var availableARRR: Double
    var transparentFundsAvailable: Bool = false
    var status: BalanceStatus
    var aTitleStatus: String
    
    
    var available: some View {
        HStack{
            Text(format(arrr: availableARRR))
                .foregroundStyle(.white)
                .scaledFont(size: Device.isLarge ? 30 : 20)
                
            Text(" \(arrr) ")
                .scaledFont(size: Device.isLarge ? 20 : 12)
                .foregroundColor(.zAmberGradient1)
        }
    }
    
    func format(arrr: Double) -> String {
        NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: arrr)) ?? "ERROR" //TODO: handle this weird stuff
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
        case .expecting(let arrr):
            return  Text("(\("expecting") ")
                           .font(.body)
                           .foregroundColor(Color.zLightGray) +
            Text("+" + format(arrr: arrr))
                           .font(.body)
                .foregroundColor(.white)
            + Text(" \(arrr))")
                .font(.body)
                .foregroundColor(Color.zLightGray)
        
        case .waiting(let change):
            return  Text("(\("expecting") ")
                                      .font(.body)
                                    .foregroundColor(Color.zLightGray) +
                       Text("+" + format(arrr: change))
                                      .font(.body)
                           .foregroundColor(.white)
                       + Text(" \(arrr))")
                           .font(.body)
                           .foregroundColor(Color.zLightGray)
            default:
                return Text("")
        }
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text("Balance")
                .foregroundStyle(Color.zLightGray)
                .scaledFont(size: Device.isLarge ? 18 : 14)
            HStack{
                available.multilineTextAlignment(.leading)
                    
                Spacer()
                Text(aTitleStatus)
                    .scaledFont(size: Device.isLarge ? 18 : 14)
                    .foregroundColor(.gray).multilineTextAlignment(.trailing)
            }
            if includeCaption {
                caption
            }
        }
    }
    
    var arrr: String {
            return "ARRR"
    }
}

struct BalanceViewHome_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ARRRBackground()
            VStack(alignment: .center, spacing: 50) {
//                BalanceViewHome(availableZec: 2.0011,status: .available(showCaption: true))
//                BalanceViewHome(availableZec: 0.0011,status: .expecting(zec: 2))
//                BalanceViewHome(availableZec: 12.2,status: .waiting(change: 5.3111112))
            }
        }
    }
}
