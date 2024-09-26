//
//  TransactionDetails.swift
//  PirateWallet
//
//  Created by Lokesh on 26/09/24.
//

import SwiftUI
import PirateLightClientKit
import AlertToast

struct TransactionDetails: View {
        
    enum Alerts {
        case explorerNotice
        case copiedItem(item: PasteboardItemModel)
    }
    var detail: DetailModel
    @State var expandMemo = false
    @Environment(\.presentationMode) var presentationMode
    @State var alertItem: Alerts?
    @State var isCopyAlertShown = false
    @State var mDisplayMemoAlert = false
    @State var mURLString:URL?
    @State var mOpenSafari = false

    var exploreButton: some View {
        Button(action: {
            self.alertItem = .explorerNotice
        }) {
            HStack {
                Spacer()
                Text("Explore".localized())
                    .foregroundColor(.white)
                Image(systemName: "arrow.up.right.square")
                    .foregroundColor(.white)
                Spacer()
            }
            .padding()
            .frame(height: Device.isLarge ? 48 : 24)
            
        }
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 1)
                .foregroundColor(.white)
        )
    }
    
    func converDateToString(aDate:Date) -> String{
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: aDate)
    }
    
    var aTitle: String {

        switch detail.status {
        case .paid(_):
            return  "To: ".localized()
        case .received:
            return "From: ".localized()
        }
    }
    
    
    var body: some View {
        
        ScrollView {
            VStack(spacing: 30) {
                VStack {
                    
                    TransactionDetailsTitle(
                        availableZec: detail.arrrAmount,status:detail.status)
                    
                    VStack(alignment: .center, spacing: 10) {
                        Spacer(minLength: 5)
                        ScrollView {
                            VStack {

                                if let fullAddr = detail.arrrAddress{
                                    TransactionRow(mTitle: aTitle, mSubTitle: fullAddr, showLine: true, isYellowColor: false)
                                }else{
                                    TransactionRow(mTitle: aTitle, mSubTitle: (detail.arrrAddress ?? "NA"), showLine: true,isYellowColor: false)
                                }
                                
//                                TransactionRowTitleSubtitle(mTitle: converDateToString(aDate: detail.date), mSubTitle: ("Processing fee: ".localized() + "\(detail.defaultFee.asHumanReadableZecBalance().toZecAmount())" + " ARRR"), showLine: true)
                                
                                TransactionRowTitleSubtitle(mTitle: "Memo".localized(), mSubTitle: (detail.memo ?? "-"), showLine: true).onTapGesture {
                                    if let _ = detail.memo {
                                        mDisplayMemoAlert = true
                                    }
                                }
                                
//                                if detail.success {
//                                    let latestHeight = PirateAppSynchronizer.shared.synchronizer?.latestHeight() //ZECCWalletEnvironment.shared.synchronizer.syncBlockHeight.value
//                                    TransactionRow(mTitle: detail.makeStatusText(latestHeight: latestHeight),mSubTitle :"", showLine: false,isYellowColor: true)
//                                } else {
//                                    TransactionRow(mTitle: "Pending".localized(),mSubTitle :"", showLine: false,isYellowColor: true)
//                                }
                                

                            }
                            .modifier(SettingsSectionBackgroundModifier())
                            
                        }
                        
                        Spacer()
                        Spacer()
//                        
//                        if detail.isMined {// If it is mined or confirmed then only show explore button
//                                Button {
//                                    self.alertItem = .explorerNotice
//                                } label: {
//                                    BlueButtonView(aTitle: "Explore".localized())
//                                }
//                        }

                    }
                    
//                    HeaderFooterFactory.header(for: detail)
//                    SubwayPathBuilder.buildSubway(detail: detail, expandMemo: self.$expandMemo)
//                        .padding(.leading, 32)
//                        .onReceive(PasteboardAlertHelper.shared.publisher) { (p) in
//                            self.alertItem = .copiedItem(item: p)
//                        }
//                    HeaderFooterFactory.footer(for: detail)
                    
                }
                
//                if detail.isMined {
//                    exploreButton
//                }
            }
            .onDisappear() {
                NotificationCenter.default.removeObserver(NSNotification.Name("CopyToClipboard"))
            }
            .onAppear() {
                NotificationCenter.default.addObserver(forName: NSNotification.Name("CopyToClipboard"), object: nil, queue: .main) { (_) in
                    isCopyAlertShown = true
                }
            }
            .padding()
        }
        .toast(isPresenting: $isCopyAlertShown){
            
            AlertToast(displayMode:  .hud, type: .regular, title:"Address Copied to clipboard!".localized())

        }
        .toast(isPresenting: $mDisplayMemoAlert){
            
            AlertToast(displayMode:  .alert, type: .regular, title:detail.memo)

        }
        .padding(.vertical,0)
        .padding(.horizontal, 8)
        .sheet(isPresented: $mOpenSafari) {
            CustomSafariView(url:self.mURLString!)
        }
        .alert(item: self.$alertItem) { item -> Alert in
            switch item {
            case .copiedItem(let p):
                return PasteboardAlertHelper.alert(for: p)
            case .explorerNotice:
                return Alert(title: Text("You are exiting your wallet".localized()),
                             message: Text("While usually an acceptable risk, you are possibly exposing your behavior and interest in this transaction by going online. OH NO! What will you do?".localized()),
                             primaryButton: .cancel(Text("NEVERMIND".localized())),
                             secondaryButton: .default(Text("SEE TX".localized()), action: {
                                
                                guard let url = UrlHandler.blockExplorerURL(for: self.detail.id) else {
                                    return
                                }
                    
                                self.mURLString  = url
                                mOpenSafari = true
                                
//                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                             }))
            }
        }
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .background(ARRRBackground().edgesIgnoringSafeArea(.all))
    }
}

struct TransactionRow: View {
    
    var mTitle:String
    
    var mSubTitle:String
    
    var showLine = false
    
    var isYellowColor = false
    
    var body: some View {

        VStack {
            HStack{
                Text(mTitle+mSubTitle).scaledFont(size: Device.isLarge ? 18 : 12).foregroundColor(isYellowColor ? Color.zARRRTextColor : Color.textTitleColor)
                                .lineLimit(nil)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(alignment: .leading)
                                .foregroundColor(Color.white)
                    .multilineTextAlignment(.leading)
                    .padding(10)
                Spacer()
                Spacer()
                if !isYellowColor && !mSubTitle.isEmpty && mSubTitle != "NA"{
                    Image(systemName: "doc.on.doc").foregroundColor(.gray)
                        .scaledFont(size: Device.isLarge ? 18 : 12).padding(.trailing, 10)
                }
                
            } .onTapGesture {
                if !isYellowColor && !mSubTitle.isEmpty && mSubTitle != "NA"{
                    copyToClipBoard(mSubTitle)
                }
            }
            
            if showLine {
                Color.gray.frame(height:CGFloat(1) / UIScreen.main.scale).padding(10)
            }
        }
    }
   
    func copyToClipBoard(_ content: String) {
        UIPasteboard.general.string = content
        printLog("content copied to clipboard")
        NotificationCenter.default.post(name: NSNotification.Name("CopyToClipboard"), object: nil)
    }
}

struct TransactionRowTitleSubtitle: View {
    
    var mTitle:String
    
    var mSubTitle:String
    
    var showLine = false
    
    var body: some View {

        VStack {
            HStack{
                Text(mTitle).font(.barlowRegular(size: Device.isLarge ? 18 : 12)).foregroundColor(Color.white)
                                .frame(height: 22,alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.middle)
                Spacer()
                Spacer()
            }
            
            HStack{
                Text(mSubTitle).font(.barlowRegular(size: Device.isLarge ? 14 : 10)).foregroundColor(Color.textTitleColor)
                                .frame(height: 22,alignment: .leading)
                    .multilineTextAlignment(.leading)
                    .truncationMode(.middle)
                Spacer()
                Spacer()
            }
            
            if showLine {
                Color.gray.frame(height:CGFloat(1) / UIScreen.main.scale)
            }
        }.padding(10)
    }
}


extension TransactionDetails.Alerts: Identifiable {
    var id: Int {
        switch self {
        case .copiedItem(_):
            return 1
        default:
            return 2
        }
    }
}
