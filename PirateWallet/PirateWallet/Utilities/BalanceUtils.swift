//
//  Untitled.swift
//  PirateWallet
//
//  Created by Lokesh on 24/09/24.
//


import Foundation
import PirateLightClientKit

extension Int64 {
    func asHumanReadableZecBalance() -> Double {
        var decimal = Decimal(self) / Decimal(PirateSDK.zatoshiPerZEC)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &decimal, 6, .bankers)
        return (rounded as NSDecimalNumber).doubleValue
    }
}

extension Double {
    
    static var defaultNetworkFee: Double = PirateSDKMainnetConstants.defaultFee().decimalValue.doubleValue

    
    func toZatoshi() -> Int64 {
        var decimal = Decimal(self) * Decimal(PirateSDK.zatoshiPerZEC)
        var rounded = Decimal()
        NSDecimalRound(&rounded, &decimal, 6, .bankers)
        return (rounded as NSDecimalNumber).int64Value
    }
    // Absolute value + network fee
    func addingZcashNetworkFee(_ fee: Double = Self.defaultNetworkFee) -> Double {
        abs(self) + fee
    }
    
    func toZecAmount() -> String {
        NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}

extension NumberFormatter {
    static var zecAmountFormatter: NumberFormatter {
        
        let fmt = NumberFormatter()
        
        fmt.alwaysShowsDecimalSeparator = false
        fmt.allowsFloats = true
        fmt.maximumFractionDigits = 8
        fmt.minimumFractionDigits = 0
        fmt.minimumIntegerDigits = 1
        return fmt
        
    }
    
    static var zeroBalanceFormatter: NumberFormatter {
        
        let fmt = NumberFormatter()
        
        fmt.alwaysShowsDecimalSeparator = false
        fmt.allowsFloats = true
        fmt.maximumFractionDigits = 0
        fmt.minimumFractionDigits = 0
        fmt.minimumIntegerDigits = 1
        return fmt
        
    }
}

