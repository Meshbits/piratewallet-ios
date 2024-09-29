//
//  ReadableBalance.swift
//  PirateWallet
//
//  Created by Lokesh on 28/09/24.
//

import Foundation
import PirateLightClientKit
struct ReadableBalance {
    var verified: Double
    var total: Double
}

extension ReadableBalance {
    init(walletBalance: WalletBalance) {
        self.init(verified: walletBalance.verified.decimalValue.doubleValue,
                        total: walletBalance.total.decimalValue.doubleValue)
    }
    
    static var zero: ReadableBalance {
        ReadableBalance(verified: 0, total: 0)
    }
    
    var unconfirmedFunds: Double {
        total - verified
    }
}
