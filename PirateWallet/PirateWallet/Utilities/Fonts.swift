//
//  Fonts.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import SwiftUI
import Foundation

extension Font {
    static func zoboto(size: CGFloat) -> Font {
        Font.custom("Zboto", size: size)
    }
    
    static func barlowRegular(size: CGFloat) -> Font {
        Font.custom("Barlow-Regular", size: size)
    }
}

struct BarlowModifier: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    var textStyle: Font.TextStyle

    init(_ textStyle: Font.TextStyle = .body) {
        self.textStyle = textStyle
    }

    func body(content: Content) -> some View {
        content.font(getFont())
    }

    func getFont() -> Font {
        switch(sizeCategory) {
        case .extraSmall:
            return Font.custom("Barlow-Regular", size: 24 * getStyleFactor())
        case .small:
            return Font.custom("Barlow-Regular", size: 24 * getStyleFactor())
        case .medium:
            return Font.custom("Barlow-Regular", size: 24 * getStyleFactor())
        case .large:
            return Font.custom("Barlow-Regular", size: 24 * getStyleFactor())
        case .extraLarge:
            return Font.custom("Barlow-Regular", size: 24 * getStyleFactor())
        case .extraExtraLarge:
            return Font.custom("Barlow-Regular", size: 24 * getStyleFactor())
        case .extraExtraExtraLarge:
            return Font.custom("Barlow-Regular", size: 24 * getStyleFactor())
        case .accessibilityMedium:
            return Font.custom("Barlow-Regular", size: 24 * getStyleFactor())
        case .accessibilityLarge:
            return Font.custom("Barlow-Regular", size: 24 * getStyleFactor())
        case .accessibilityExtraLarge:
            return Font.custom("Barlow-Regular", size: 24 * getStyleFactor())
        case .accessibilityExtraExtraLarge:
            return Font.custom("Barlow-Regular", size: 24 * getStyleFactor())
        case .accessibilityExtraExtraExtraLarge:
            return Font.custom("Barlow-Regular", size: 24 * getStyleFactor())
        @unknown default:
            return Font.custom("Barlow-Regular", size: 24 * getStyleFactor())
        }
    }

    func getStyleFactor() -> CGFloat {
        switch textStyle {
        case .caption:
            return 0.6
        case .footnote:
            return 0.7
        case .subheadline:
            return 0.8
        case .callout:
            return 0.9
        case .body:
            return 1.0
        case .headline:
            return 1.2
        case .title:
            return 1.5
        case .largeTitle:
            return 2.0
        @unknown default:
            return 1.0
        }
    }

}

