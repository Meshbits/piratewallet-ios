//
//  ARRR+SwiftUI.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import Foundation
import SwiftUI

extension Text {
    static func subtitle(text: String) -> Text {
        Text(text)
        .foregroundColor(.zLightGray)
        .font(.footnote)
    }
}

extension ARRRButton {
    static func nukeButton() -> ARRRButton {
        ARRRButton(color: Color.red, fill: Color.clear, text: "NUKE WALLET".localized())
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}


struct SmallRecoveryWalletButtonView : View {
    
    @Binding var imageName: String
    @Binding var title: String

    
    
    var body: some View {
        ZStack {

            Image(imageName).resizable().frame(width: 175.0, height:84).padding(.top,5)
            
            Text(title).foregroundColor(Color.gray)
                .frame(width: 175.0, height:84).padding(10)
                .cornerRadius(15)
                .multilineTextAlignment(.center)
        }.frame(width: 175.0, height:84)
    }
}

struct SmallBlueButtonView : View {
    
    @State var aTitle: String = ""
    
    var body: some View {
        ZStack {
            
            Image("bluebuttonbackground").resizable().frame(width: 175.0, height:84).padding(.top,5)
            
            Text(aTitle).foregroundColor(Color.black)
                .frame(width: 175.0, height:84)
                .cornerRadius(15)
                .multilineTextAlignment(.center)
        }.frame(width: 175.0, height:84)
        
    }
}


struct ForegroundPlaceholderModifier: ViewModifier {

var backgroundColor = Color(.systemBackground)

func body(content: Content) -> some View {
    content
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color.init(red: 29.0/255.0, green: 32.0/255.0, blue: 34.0/255.0))
                .softInnerShadow(RoundedRectangle(cornerRadius: 12), darkShadow: Color.init(red: 0.26, green: 0.27, blue: 0.3), lightShadow: Color.init(red: 0.06, green: 0.07, blue: 0.07), spread: 0.05, radius: 2))
    }
}

extension View {
    func hidden(_ shouldHide: Bool) -> some View {
        opacity(shouldHide ? 0 : 1)
    }
}

struct BackgroundPlaceholderModifierRescanOptions: ViewModifier {

var backgroundColor = Color(.systemBackground)

func body(content: Content) -> some View {
    content
        .padding(5)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color.init(red: 29.0/255.0, green: 32.0/255.0, blue: 34.0/255.0))
                .softInnerShadow(RoundedRectangle(cornerRadius: 12), darkShadow: Color.init(red: 0.06, green: 0.07, blue: 0.07), lightShadow: Color.init(red: 0.26, green: 0.27, blue: 0.3), spread: 0.05, radius: 2))
        
    }
}


struct SettingsSectionBackgroundModifier: ViewModifier {

        var backgroundColor = Color(.systemBackground)

        func body(content: Content) -> some View {
            content
                .background(
                    RoundedRectangle(cornerRadius: 12).fill(Color.init(red: 29.0/255.0, green: 32.0/255.0, blue: 34.0/255.0))
                        .softInnerShadow(RoundedRectangle(cornerRadius: 12), darkShadow: Color.init(red: 0.06, green: 0.07, blue: 0.07), lightShadow: Color.init(red: 0.26, green: 0.27, blue: 0.3), spread: 0.05, radius: 2))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
}


extension Image {
    static func statusImage(for model: TransactionDetailModel) -> Image {
        var imageName = "gray_shield"
        switch model.transaction {
        case .sent(let overview):
            imageName = "senticon"
        case .received(let overview):
            imageName = "receiveicon"
        case .pending(let overview):
            imageName = "senticon"
        case .cleared(let overview):
            // Cleared means transaction is cleared - sent or received
            if model.zatoshi.amount > 0 {
                imageName = "receiveicon"
            }else{
                imageName = "senticon"
            }
        }
        
        return Image(imageName)
    }
}

extension String {
    static func transactionSubTitle(for model: TransactionDetailModel) -> String {
        var transactionSubTitle = "Pending".localized()
        
        switch model.transaction {
            case .sent(let overview):
                transactionSubTitle = ("Sent".localized())
            case .received(let overview):
                transactionSubTitle = ("Received".localized())
            case .pending(let overview):
                transactionSubTitle = ("Pending".localized())
            case .cleared(let overview):
            // Cleared means transaction is cleared - sent or received 
            if model.zatoshi.amount > 0 {
                transactionSubTitle = ("Received".localized())
            }else{
                transactionSubTitle = ("Sent".localized())
            }
            
                
        }
                
//        transactionSubTitle = transactionSubTitle + (model.arrrAddress ?? "NA".localized())
        
        return transactionSubTitle
    }
}

extension LinearGradient {
    static func gradient(for cardType: DetailModel.Status) -> LinearGradient {
        var gradient = Gradient.paidCard
        switch cardType {
    
        case .paid(let success):
            gradient = success ? Gradient.paidCard : Gradient.failedCard
        case .received:
            gradient = Gradient.receivedCard
        }
        return LinearGradient(
            gradient: gradient,
            startPoint: UnitPoint(x: 0.3, y: 0.7),
            endPoint: UnitPoint(x: 0.5, y: 1)
        )
    }
}


extension Date {
    var aFormattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        return dateFormatter.string(from: self)
    }

    var aNewFormattedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd, yyyy"
        return dateFormatter.string(from: self)
    }
}

struct BackgroundPlaceholderModifier: ViewModifier {

    var backgroundColor = Color(.systemBackground)

    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 12).fill(Color.init(red: 29.0/255.0, green: 32.0/255.0, blue: 34.0/255.0))
                    .softInnerShadow(RoundedRectangle(cornerRadius: 12), darkShadow: Color.init(red: 0.06, green: 0.07, blue: 0.07), lightShadow: Color.init(red: 0.26, green: 0.27, blue: 0.3), spread: 0.05, radius: 2))
            .padding()
        }
}


struct ForegroundPlaceholderModifierHomeButtons: ViewModifier {

var backgroundColor = Color(.systemBackground)

func body(content: Content) -> some View {
    content
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 30).fill(Color.init(red: 29.0/255.0, green: 32.0/255.0, blue: 34.0/255.0))
                .softInnerShadow(RoundedRectangle(cornerRadius: 30), darkShadow: Color.init(red: 0.26, green: 0.27, blue: 0.3), lightShadow: Color.init(red: 0.06, green: 0.07, blue: 0.07), spread: 0.05, radius: 2))
        .padding()
    }
}


struct FullScreenImageView: View {
    @Binding var qrImage: Image
    let dragGesture = DragGesture()
    var body: some View {
        ZStack{
            ARRRBackground()
            VStack{
                qrImage.resizable().aspectRatio(contentMode: .fit)
                .frame(width: 250, height: 250)
            }.padding(.top,50)
            .padding(.bottom,50)
            .highPriorityGesture(dragGesture)
        }
    }

}


extension String {
    func slice(into pieces: Int) -> [String] {
        guard pieces > 0 else { return [] }
        let chunkSize = Int(ceilf(Float(self.count) / Float(pieces)))
        return chunked(intoAtMost: chunkSize)
    }
    func chunked(intoAtMost size: Int) -> [String] {
        return stride(from: 0, to: self.count, by: size).map {
            let start = self.index(self.startIndex, offsetBy: $0)
            let end = self.index(start, offsetBy: size, limitedBy: self.endIndex) ?? self.endIndex
            return String(self[start ..< end])
        }
    }
}
