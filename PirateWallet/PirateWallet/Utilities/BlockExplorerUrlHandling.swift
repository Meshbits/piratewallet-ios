//
//  BlockExplorerUrlHandling.swift
//  PirateWallet
//
//  Created by Lokesh on 26/09/24.
//

import Foundation
import PirateLightClientKit

class UrlHandler {
    
    static func blockExplorerURL(for txId: String) -> URL? {
        blockExplorerURLMainnet(for: txId)
    }
    
    static func blockExplorerURLMainnet(for txId: String) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.host = "explorer.pirate.black"
        urlComponents.scheme = "https"
        urlComponents.path = "/tx"
        
        return urlComponents.url?.appendingPathComponent(txId)
    }
}
