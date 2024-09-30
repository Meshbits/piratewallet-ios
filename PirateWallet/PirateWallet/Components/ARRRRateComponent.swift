//
//  ARRRRateComponent.swift
//  PirateWallet
//
//  Created by Lokesh on 30/09/24.
//


import SwiftUI

struct ARRRRateComponent: View {
    @Binding var selectedIndex: Int?
    var onSelect: ((Int) -> ())?
    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ForEach(1 ..< 6) { index in
                Toggle(isOn: .constant(self.selectedIndex == index)) {
                    Text(String(index))
                        .font(Font.zoboto(size: 28))
                        .foregroundColor(.black)
                }.toggleStyle(RatingToggleStyle(
                    shape: Circle(),
                    padding: 20,
                    action: {
                        self.selectedIndex = index
                        self.onSelect?(index)
                })
                )
                
            }
        }
    }
}


struct RatingToggleStyle<S :Shape>: ToggleStyle {
    let shape: S
    var padding: CGFloat = 8
    var action = {}
    func makeBody(configuration: Self.Configuration) -> some View {
        ZStack(alignment: .center) {
            Button(action: {
                configuration.isOn.toggle()
                self.action()
            }) {
                configuration.label
                    .contentShape(shape)
                    .frame(width: 50, height: 50, alignment: .center)
            }
            .background(
                SimpleRateBackground(isHighlighted: configuration.isOn, shape: shape)
            )
        }
    }
}

struct SimpleRateBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S
    
    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(Color.zYellow)
                
            } else {
                shape
                    .fill(Color.white)
            }
        }
    }
}

struct ARRRRateComponent_Previews: PreviewProvider {
    static var previews: some View {
        ARRRRateComponent(selectedIndex: .constant(3))
    }
}
