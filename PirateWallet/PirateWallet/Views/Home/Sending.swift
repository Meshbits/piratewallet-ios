//
//  Sending.swift
//  PirateWallet
//
//  Created by Lokesh on 06/12/24.
//


import SwiftUI
import Combine
import PirateLightClientKit

struct Sending: View {
    
    let dragGesture = DragGesture()
    @EnvironmentObject var flow: SendFlowEnvironment
//    @State var details: DetailModel? = nil
    @Environment(\.presentationMode) var presentationMode
    var errorMessage: String {
        guard let e = flow.error else {
            return "thing is that we really don't know what just went down, sorry!"
        }
        
        return "\(e)"
    }
 
    var showErrorAlert: Alert {
        var errorMessage = "an error ocurred while submitting your transaction"
        
        if let error = self.flow.error {
            errorMessage = "\(error)"
        }
        return Alert(title: Text("Error"),
                     message: Text(errorMessage),
                     dismissButton: .default(
                        Text("button_close"),
                        action: {
                            self.flow.close()
                            NotificationCenter.default.post(name: NSNotification.Name("DismissPasscodeScreenifVisible"), object: nil)
                     }
            )
        )
    }
    
    var sendText: some View {
        guard flow.error == nil else {
            return Text("label_unabletosend".localized())
        }
        
        return flow.isDone ? Text("send_sent".localized()).foregroundColor(.white) :     Text(String(format: NSLocalizedString("send_sending", comment: ""), flow.amount)).foregroundColor(.white)
    }
    
    var body: some View {
        ZStack {
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 40) {
                Spacer()
                sendText
                    .foregroundColor(.white)
                    .scaledFont(size: 22)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                Text("\(flow.address)")
                    .foregroundColor(.white)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .scaledFont(size: 15)
                
                if !flow.isDone {
                    LottieAnimation(isPlaying: true,
                                    filename: "lottie_sending",
                                    animationType: .circularLoop)
                        .frame(height: 48)
                    
                }
                Spacer()
//                if self.flow.isDone && self.$flow.pendingTx != nil {
//                    Button(action: {
//                        guard let pendingTx = self.flow.pendingTx  else {
//                            printLog("Attempt to open transaction details in sending screen with no pending transaction in send flow")
//                            self.flow.close() // close this so it does not get stuck here
//                            return
//                        }
//                        
//                        let latestHeight = PirateAppSynchronizer.shared.synchronizer?.latestHeight()
////                        let latestHeight = ZECCWalletEnvironment.shared.synchronizer.syncBlockHeight.value
//                        self.details = DetailModel(pendingTransaction: pendingTx,latestBlockHeight: latestHeight)
//                        printLog("sendFinalDetails")
//                        
//                    }) {
//                        
//                        SendRecieveButtonView(title: "button_seedetails".localized(),isSyncing:Binding.constant(false))
//                        
//                    }
//                }
                
                if flow.isDone {
                    Button(action: {
                        printLog("sendFinalClose")
                        self.flow.close()
                        NotificationCenter.default.post(name: NSNotification.Name("DismissPasscodeScreenifVisible"), object: nil)
                    }) {
                        SendRecieveButtonView(title: "button_done".localized(),isSyncing:Binding.constant(false))
                    }
                }
            }
            .padding([.horizontal, .bottom], 40)
        }
        .highPriorityGesture(dragGesture)
//        .sheet(item: $details, onDismiss: {
//            self.flow.close()
//            NotificationCenter.default.post(name: NSNotification.Name("DismissPasscodeScreenifVisible"), object: nil)
//        }){ item in
//            TxDetailsWrapper(row: item)
//        }
        .alert(isPresented: self.$flow.showError) {
            showErrorAlert
        }
        .onAppear() {
            printLog("sendFinalOnAppear")
            self.flow.preSend()
        }
    }
}
