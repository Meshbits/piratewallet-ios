//
//  String+ARRR.swift
//  PirateWallet
//
//  Created by Lokesh on 23/09/24.
//

import Foundation
import PirateLightClientKit

extension String {
    /**
     network aware ARRR string. When on mainnet it will read ARRR and ARRR when on Testnet
     */
    static var ARRR: String {
        return "ARRR"
    }
    
    var isValidShieldedAddress: Bool {
        DerivationTool(networkType: kPirateNetwork.networkType).isValidSaplingAddress(self)
    }
    
    var isValidTransparentAddress: Bool {
        DerivationTool(networkType: kPirateNetwork.networkType).isValidTransparentAddress(self)
    }
    
    var isValidAddress: Bool {
        self.isValidShieldedAddress || self.isValidTransparentAddress
    }
    
    /**
     This only shows an abbreviated and redacted version of the Z addr for UI purposes only
     */
    var shortARRRaddress: String? {
        guard isValidAddress else { return nil }
        return String(self[self.startIndex ..< self.index(self.startIndex, offsetBy: 8)])
            + "..."
            + String(self[self.index(self.endIndex, offsetBy: -8) ..< self.endIndex])
    }
}
