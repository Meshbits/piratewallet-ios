//
//  MnemonicSeedProvider.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import Foundation
import MnemonicSwift
class MnemonicSeedProvider: MnemonicSeedPhraseHandling {
    
    static let `default` = MnemonicSeedProvider()
       
    private init(){}
    
    func randomMnemonic() throws -> String {
        try Mnemonic.generateMnemonic(strength: 256)
    }
    
    func randomMnemonicWords() throws -> [String] {
        try randomMnemonic().components(separatedBy: " ")
    }
    
    func savedMnemonicWords() throws -> [String]{
//        let phrase = try SeedManager.default.exportPhrase()
        return [""] // phrase.components(separatedBy: " ")
    }
    
    func toSeed(mnemonic: String) throws -> [UInt8] {
        let data = try Mnemonic.deterministicSeedBytes(from: mnemonic)
        return [UInt8](data)
    }
    
    func asWords(mnemonic: String) throws -> [String] {
        mnemonic.components(separatedBy: " ")
    }
    
    func isValid(mnemonic: String) throws {
        try Mnemonic.validate(mnemonic: mnemonic)
    }
}
