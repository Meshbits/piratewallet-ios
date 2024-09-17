//
//  MnemonicSeedPhraseHandling.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import Foundation
enum MnemonicError: Error {
    case invalidSeed
    case checksumFailed
}

protocol MnemonicSeedPhraseHandling {
    /**
     random 24 words mnemonic phrase
     */
    func randomMnemonic() throws -> String
    /**
    random 24 words mnemonic phrase as array of words
    */
    func randomMnemonicWords() throws -> [String]
    
    /**
     generate deterministic seed from mnemonic phrase
     */
    func toSeed(mnemonic: String) throws -> [UInt8]
    
    /**
     get this mnemonic
    */
    func asWords(mnemonic: String) throws -> [String]
    
    /**
     validates whether the given mnemonic is correct
     */
    func isValid(mnemonic: String) throws
}
