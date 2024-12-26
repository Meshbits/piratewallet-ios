//
//  ConfirmTransaction.swift
//  PirateWallet
//
//  Created by Lokesh on 06/12/24.
//

import SwiftUI
import PirateLightClientKit

struct ConfirmTransaction: View {
    @EnvironmentObject var flow: SendFlowEnvironment
    @State var homeViewModel: HomeViewModel
    @Environment(\.presentationMode) var presentationMode
    var body: some View {

            ZStack {
                ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack {

            List {
                
                
                ConfirmTableSectionHeaderView(aTitle:"From: ".localized())
                    .listRowSeparator(.hidden)
                    HStack{
                        Text(homeViewModel.arrrAddress ?? "")
                            .foregroundColor(.white)
                            .scaledFont(size: 15)
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.leading,10)
                    .frame(minHeight: 50)
                    .listRowSeparator(.hidden)
                
                    ConfirmTableSectionHeaderView(aTitle:"To: ".localized()).listRowSeparator(.hidden)
                
                    HStack{
                        Text("\(flow.address)").multilineTextAlignment(.leading)
                            .lineLimit(nil)
                            .scaledFont(size: 15)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    .listRowSeparator(.hidden)
                    .padding(.leading,10)
                    .frame(minHeight: 50)
                    
                ConfirmTableSectionHeaderView(aTitle:"Transaction Amount: ".localized()).listRowSeparator(.hidden)
                     HStack{
                        Text("\(flow.amount)" + " ARRR")
                            .scaledFont(size: 15)
                            .frame(alignment: .leading)
                         Spacer()
                     }
                     .padding(.leading,10)
                     .frame(height: 40).listRowSeparator(.hidden)
                    
                ConfirmTableSectionHeaderView(aTitle:"Processing fee: ".localized().localized()).listRowSeparator(.hidden)
                    HStack{
                        Text("\(Int64(10_000).asHumanReadableZecBalance())" + " ARRR")
                            .scaledFont(size: 15)
                            .frame(alignment: .leading)
                        Spacer()
                    }
                    .padding(.leading,10)
                    .frame(height: 40).listRowSeparator(.hidden)
                   
                
                
            }
            .listRowSeparator(.hidden)
            .background(Rectangle().fill(Color.init(red: 24.0/255.0, green: 28.0/255.0, blue: 29.0/255.0)))
//            .modifier(BackgroundPlaceholderModifierRescanOptions())
//            .overlay(
//                RoundedRectangle(cornerRadius: 20)
//                    .stroke(Color.zGray, lineWidth: 1.0)
//            )
            .padding()
         
         BlueButtonView(aTitle: "Confirm".localized()).onTapGesture {
            self.presentationMode.wrappedValue.dismiss()
            NotificationCenter.default.post(name: NSNotification.Name("ConfirmedTransaction"), object: nil)
         }
         .frame(width: 100)
        }
        }.ARRRNavigationBar(leadingItem: {
            EmptyView()
         }, headerItem: {
                HStack {
                    Text("Confirm Transaction")
                        .foregroundColor(.white)
                        .scaledFont(size: Device.isLarge ? 20 : 12)
                        .multilineTextAlignment(.center)
                }
                .padding(.top,40)
         }, trailingItem: {
             ARRRCloseButton(action: {
                 presentationMode.wrappedValue.dismiss()
                 }).frame(width: 20, height: 20)
             .padding(.top,40)
         })

        .padding(.top,20)
        .padding(.bottom,20)
        
    }
}

struct ConfirmTableSectionHeaderView : View {
    @State var aTitle: String = ""

    var body: some View {
        
        ZStack {
            
            VStack(alignment: .trailing, spacing: 6) {

              Text(aTitle)
                .scaledFont(size: 17).foregroundColor(Color.zSettingsSectionHeader)
                                
              .frame(maxWidth: .infinity, alignment: .leading)
              .padding(.leading, 50)
              
            }
            .frame(width: 380)
           
        }
    }
}


//struct ConfirmTransaction_Previews: PreviewProvider {
//    static var previews: some View {
//        ConfirmTransaction()
//    }
//}
