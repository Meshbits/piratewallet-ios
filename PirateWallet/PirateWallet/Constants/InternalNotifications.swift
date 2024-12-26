//
//  InternalNotifications.swift
//  PirateWallet
//
//  Created by Lokesh on 28/09/24.
//

import Foundation

extension Notification.Name {
    static let sendFlowClosed = Notification.Name("sendFlowClosed")
    static let sendFlowStarted = Notification.Name("sendFlowStarted")
    static let openTransactionScreen = Notification.Name("openTransactionScreen")
    static let qrCodeScanned = Notification.Name(rawValue: "qrCodeScanned")
    static let qrZaddressScanned = Notification.Name(rawValue: "qrZaddressScanned")
}

