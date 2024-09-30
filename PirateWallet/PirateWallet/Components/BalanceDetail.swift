//
//  BalanceDetail.swift
//  PirateWallet
//
//  Created by Lokesh on 24/09/24.
//


import SwiftUI
import PirateLightClientKit

enum BalanceStatus {
    case available(showCaption: Bool)
    case expecting(arrr: Double)
    case waiting(change: Double)
}

struct BalanceDetail: View {
    var availableZec: Double
    var transparentFundsAvailable: Bool = false
    var status: BalanceStatus
    
    var available: some View {
        HStack{
            Text(format(zec: availableZec) + " \(zec) ")
                .foregroundColor(.zLightGray)
                .scaledFont(size: 14)
                
            Text("balance_available".localized())
                .foregroundColor(Color.zAmberGradient1)
                .scaledFont(size: 14)
               
            Text(transparentFundsAvailable ? "†" : "")
                    .foregroundColor(.zTransparentBlue)
                    .font(.footnote)

        }
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
        VStack(alignment: .center) {
            available
            if includeCaption {
                caption
            }
        }
    }
    
    var zec: String {
        return "ARRR"
    }
}

struct BalanceDetail_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            ARRRBackground()
            VStack(alignment: .center, spacing: 50) {
                BalanceDetail(availableZec: 2.0011,status: .available(showCaption: true))
                BalanceDetail(availableZec: 0.0011,status: .expecting(arrr: 2))
                BalanceDetail(availableZec: 12.2,status: .waiting(change: 5.3111112))
            }
        }
    }
}

extension PirateAppSynchronizer {
    var balanceStatus: BalanceStatus {
        return BalanceStatus.available(showCaption: true)
//        let verifiedBalance = try! await self.synchronizer?.getShieldedVerifiedBalance().decimalValue.int64Value
//        let balance = try! await self.synchronizer?.getShieldedVerifiedBalance().decimalValue.int64Value
//        
//        let difference = verifiedBalance - balance
//        if difference.isZero {
//            return BalanceStatus.available(showCaption: true)
//        } else if difference > 0 {
//            return BalanceStatus.expecting(zec: abs(difference))
//        } else {
//            return BalanceStatus.waiting(change: abs(difference))
//        }
    }
}
