//
//  PirateAppConfig.swift
//  PirateWallet
//
//  Created by Lokesh on 19/09/24.
//

import Foundation
import PirateLightClientKit
import MnemonicSwift

// swiftlint:disable force_try
enum PirateAppConfig {
    struct SynchronizerInitData {
        let alias: ZcashSynchronizerAlias
        let birthday: BlockHeight
        let seed: [UInt8]
    }

    static let host = "lightd1.pirate.black"
    static let port: Int = 443
    static var defaultBirthdayHeight: BlockHeight = 1390000
    static var defaultSeed = try! Mnemonic.deterministicSeedBytes(from: "eyebrow luggage boy enemy stamp lunch middle slab mother bacon confirm again tourist idea grain pink angle comic question rabbit pole train dragon grape")

    static var address: String {
        "\(host):\(port)"
    }

    static var endpoint: LightWalletEndpoint {
        return LightWalletEndpoint(address: self.host, port: self.port, secure: true, streamingCallTimeoutInMillis: 10 * 60 * 60 * 1000)
    }
}

extension PirateSDK {
    static var isMainnet: Bool {
        switch kPirateNetwork.networkType {
        case .mainnet:  return true
        case .testnet:  return false
        }
    }
}
