//
//  PirateChainPaymentURIProtocol.swift
//  PirateWallet
//
//  Created by Lokesh on 30/09/24.
//

import Foundation

protocol PirateChainPaymentURIProtocol {
    
    var address: String? { get }
    
    var amount: Double? { get }
    
    var label: String? { get }
    
    var message: String? { get }
    
    var parameters: [String: ARRRParameter]? { get }
    
}
