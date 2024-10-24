//
//  ReceiveFunds.swift
//  PirateWallet
//
//  Created by Lokesh on 25/10/24.
//

import SwiftUI
import PirateLightClientKit
struct ReceiveFunds: View {
        
    @Environment(\.presentationMode) var presentationMode
    @State var selectedTab: Int = 0
    @State var qrImage : Image?
    @State var homeViewModel: HomeViewModel
    var body: some View {
        NavigationView {
            
            ZStack {
                ARRRBackground().edgesIgnoringSafeArea(.all)
                VStack(alignment: .center, spacing: 10, content: {
                    DisplayAddress(address: homeViewModel.arrrAddress ?? "",
                                   title: "address_shielded".localized(),
                                   badge: Image("skullcoin"),
                                   qrImage: qrImage  ?? Image("QrCode"),
                                   accessoryContent: { EmptyView() })
                        
                })
            }.ARRRNavigationBar(leadingItem: {
                EmptyView()
             }, headerItem: {
                 HStack{
                    Text("receive_title".localized())
                         .font(.barlowRegular(size: Device.isLarge ? 26 : 16)).foregroundColor(Color.zSettingsSectionHeader)
                         .frame(alignment: Alignment.center).padding(.top,40)
                 }
             }, trailingItem: {
                 ARRRCloseButton(action: {
                     
                     if #available(iOS 16.0, *) {
                         presentationMode.wrappedValue.dismiss()
                     }else{
                          if UIApplication.shared.windows.count > 0 {
                              UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: nil)
                          }
                     }
                     

                     }).frame(width: Device.isLarge ? 30 : 15, height: Device.isLarge ? 30 : 15).padding(.top,40)
             })
            .navigationBarHidden(true)
//            .navigationBarTitle(Text("receive_title"),
//                                           displayMode: .inline)
//                       .navigationBarItems(trailing: ZcashCloseButton(action: {
//                           tracker.track(.tap(action: .receiveBack), properties: [:])
//                           presentationMode.wrappedValue.dismiss()
//                           }).frame(width: 30, height: 30))
        }
        .onAppear() {
            
        }
    }
}
