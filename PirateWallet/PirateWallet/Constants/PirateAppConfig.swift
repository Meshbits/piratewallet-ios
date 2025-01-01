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

    static var host = "lightd1.pirate.black"
    static var port: Int = 443
    static var defaultBirthdayHeight: BlockHeight = 1390000
    static var defaultBirthdayHeightNewWallet: BlockHeight = 2560000
    static var defaultSeed = try! Mnemonic.deterministicSeedBytes(from: "eyebrow luggage boy enemy stamp lunch middle slab mother bacon confirm again tourist idea grain pink angle comic question rabbit pole train dragon grape")
    static var memoLengthLimit: Int = 512
    static var address: String {
        "\(host):\(port)"
    }
    static var arrrAddress: String {
        "\(host)"
    }

    static func resetConfigDefaults () {
        host = "lightd1.pirate.black"
        port = 443
        defaultBirthdayHeight = 1390000
        defaultBirthdayHeightNewWallet = 2560000
        defaultSeed = try! Mnemonic.deterministicSeedBytes(from: "eyebrow luggage boy enemy stamp lunch middle slab mother bacon confirm again tourist idea grain pink angle comic question rabbit pole train dragon grape")
        memoLengthLimit = 512
    }
    
    static var endpoint: LightWalletEndpoint {
        return LightWalletEndpoint(address: self.host, port: self.port, secure: true, streamingCallTimeoutInMillis: 10 * 60 * 60 * 1000)
    }
}

public enum LocalSyncStatus : Int, Codable{
    case notStarted = 0
    case inProgress = 1
    case completed = 2
}


extension PirateSDK {
    static var isMainnet: Bool {
        switch kPirateNetwork.networkType {
        case .mainnet:  return true
        case .testnet:  return false
        }
    }
}
