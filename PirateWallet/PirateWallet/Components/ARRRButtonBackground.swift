//
//  ARRRButtonBackground.swift
//  PirateWallet
//
//  Created by Lokesh on 30/09/24.
//


import SwiftUI

enum ARRRFillStyle {
    case gradient(gradient: LinearGradient)
    case solid(color: Color)
    case outline(color: Color, lineWidth: CGFloat)
    
    func fill<S: Shape>(_ s: S) -> AnyView {
        switch self {
        case .gradient(let g):
            return AnyView (s.fill(g))
        case .solid(let color):
            return AnyView(s.fill(color))
        case .outline(color: let color, lineWidth: let lineWidth):
            return AnyView(
                s.stroke(color, lineWidth: lineWidth)
            )
        }
    }
}

struct ARRRButtonBackground: ViewModifier {
    
    enum BackgroundShape {
        case chamfered(fillStyle: ARRRFillStyle)
        case rounded(fillStyle: ARRRFillStyle)
        case roundedCorners(fillStyle: ARRRFillStyle)
    }
    
    var buttonShape: BackgroundShape
    init(buttonShape: BackgroundShape) {
        self.buttonShape = buttonShape
    }
    
    func backgroundWith(geometry: GeometryProxy, backgroundShape: BackgroundShape) -> AnyView {
        
        switch backgroundShape {
        case .chamfered(let fillStyle):
            
            return AnyView (
                fillStyle.fill( ARRRChamferedButtonBackground(cornerTrim: min(geometry.size.height, geometry.size.width) / 4.0))
            )
        case .rounded(let fillStyle):
            return AnyView(
                fillStyle.fill(
                    ARRRRoundedButtonBackground()
                )
            )
        case .roundedCorners(let fillStyle):
            return AnyView(
                fillStyle.fill(
                    ARRRRoundCorneredButtonBackground()
                )
            )
        
        }
    }
    
    func body(content: Content) -> some View {
        ZStack {
            GeometryReader { geometry in
                self.backgroundWith(geometry: geometry, backgroundShape: self.buttonShape)
            }
            content
            
        }
    }
}

extension Text  {
    func zcashButtonBackground(shape: ARRRButtonBackground.BackgroundShape) -> some View {
        self.modifier(ARRRButtonBackground(buttonShape: shape))
    }
}
