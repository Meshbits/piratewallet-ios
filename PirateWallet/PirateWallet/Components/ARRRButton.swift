//
//  ARRRButton.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import SwiftUI

struct ARRRButton: View {
    
    enum BackgroundShape {
        case chamfered
        case rounded
        case roundedCorners
    }
    var buttonShape: BackgroundShape = .chamfered
    var color = Color.zYellow
    var fill = Color.black
    var text: String
    
    func backgroundWith(geometry: GeometryProxy, backgroundShape: BackgroundShape) -> AnyView {
        
        switch backgroundShape {
        case .chamfered:
            
            return AnyView (
                Group {
                    ARRRChamferedButtonBackground(cornerTrim: min(geometry.size.height, geometry.size.width) / 4.0)
                    .fill(self.fill)
                
                    ARRRChamferedButtonBackground(cornerTrim: min(geometry.size.height, geometry.size.width) / 4.0)
                    .stroke(self.color, lineWidth: 1.0)
                }
            )
        case .rounded:
            return AnyView(
                EmptyView()
            )
        case .roundedCorners:
            return AnyView(
                EmptyView()
            )
        }
    }
    var body: some View {
        
        ZStack {
            GeometryReader { geometry in
                self.backgroundWith(geometry: geometry, backgroundShape: self.buttonShape)
            }
            Text(self.text)
                .foregroundColor(self.color)
                .font(.body)
            
        }.frame(minWidth: 30, idealWidth: 30, minHeight: 30, idealHeight: 30)
    }
}


struct ARRRRoundCorneredButtonBackground: Shape {
    var cornerRadius: CGFloat = 12
    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: cornerRadius).path(in: rect)
    }
}

struct ARRRRoundedButtonBackground: Shape {
    func path(in rect: CGRect) -> Path {
        RoundedRectangle(cornerRadius: rect.height).path(in: rect)
    }
}

struct ARRRChamferedButtonBackground: Shape {
    var cornerTrim: CGFloat
    func path(in rect: CGRect) -> Path {
        
        Path {
            path in
            
            path.move(
                to: CGPoint(
                    x: cornerTrim,
                    y: rect.origin.y
                )
            )
            
            // top border
            path.addLine(
                to: CGPoint(
                    x: rect.width - cornerTrim,
                    y: rect.origin.y
                )
            )
            
            // top right lip
            path.addLine(
                to: CGPoint(
                    x: rect.width,
                    y: cornerTrim
                )
            )
            
            // right border
            
            path.addLine(
                to: CGPoint(
                    x: rect.width,
                    y: rect.height - cornerTrim
                )
            )
            
            // bottom right lip
            path.addLine(
                to: CGPoint(
                    x: rect.width - cornerTrim,
                    y: rect.height
                )
            )
            
            // bottom border
            
            path.addLine(
                to: CGPoint(
                    x: cornerTrim,
                    y: rect.height
                )
            )
            
            // bottom left lip
            
            path.addLine(
                to: CGPoint(
                    x: rect.origin.x,
                    y: rect.height - cornerTrim
                )
            )
            
            // left border
            
            path.addLine(
                to: CGPoint(
                    x: rect.origin.x,
                    y: cornerTrim
                )
            )
            
            // top left lip
            path.addLine(
                to: CGPoint(
                    x: rect.origin.x + cornerTrim,
                    y: rect.origin.y
                )
            )
        }
    }
}

struct ARRRButton_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
            VStack {
                ARRRButton(color: Color.zYellow, fill: Color.clear, text: "Create New Wallet")
                .frame(width: 300, height: 60)
            
                ARRRButton(color: .black, fill: Color.clear, text: "Create New Wallet")
                .frame(width: 300, height: 60)
            }
        }
    }
}
