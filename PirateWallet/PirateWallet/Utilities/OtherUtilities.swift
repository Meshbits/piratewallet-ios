//
//  OtherUtilities.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import SwiftUI
import Combine

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    var size: CGFloat

    func body(content: Content) -> some View {
       let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom("Barlow-Regular", size: scaledSize))
    }
}

@available(iOS 13, macCatalyst 13, tvOS 13, watchOS 6, *)
extension View {
    func scaledFont(size: CGFloat) -> some View {
        return self.modifier(ScaledFont(size: size))
    }
}

public func printLog<T>(_ message : T,
                        _ file : String = #file,
                        _ lineNumber: Int = #line,
                        _ function : String = #function) {
    var vMess = "\((file as NSString).lastPathComponent) | \(lineNumber) | \(function)" + " | "
    vMess += "\n\(message)"
    print("\(vMess)\n")
}
