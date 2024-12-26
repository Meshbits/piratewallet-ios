//
//  Sending.swift
//  PirateWallet
//
//  Created by Lokesh on 06/12/24.
//


import SwiftUI
import Combine
import PirateLightClientKit
import UIKit
import Foundation

struct Sending: View {
    
    let dragGesture = DragGesture()
    @EnvironmentObject var flow: SendFlowEnvironment
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
                
                if flow.isDone {
                    Button(action: {
                        printLog("sendFinalClose")
                        self.flow.close()
                        NotificationCenter.default.post(name: NSNotification.Name("DismissPasscodeScreenifVisible"), object: nil)
                        self.presentationMode.wrappedValue.dismiss()
                    }) {
                        SendRecieveButtonView(title: "button_done".localized(),isSyncing:Binding.constant(false))
                    }
                }
            }
            .padding([.horizontal, .bottom], 40)
        }
        .highPriorityGesture(dragGesture)
        .alert(isPresented: self.$flow.showError) {
            showErrorAlert
        }
        .onAppear() {
            printLog("sendFinalOnAppear")
            self.send()
        }
    }
    
    
    func send() {
        Task { @MainActor in
            guard
                let zec = NumberFormatter.zcashNumberFormatter.number(from: flow.amount).flatMap({ Zatoshi($0.int64Value) })
            else {
                printLog("WARNING: Information supplied is invalid")
                return
            }

            let derivationTool = DerivationTool(networkType: kPirateNetwork.networkType)
            guard let spendingKey = try? derivationTool.deriveUnifiedSpendingKey(seed: PirateAppConfig.defaultSeed, accountIndex: 0) else {
                printLog("NO SPENDING KEY")
                return
            }

            Task { @MainActor in
                if let aSynchronizer = PirateAppSynchronizer.shared.synchronizer  {
                    do {
                        let pendingTransaction = try await aSynchronizer.sendToAddress(
                            spendingKey: spendingKey,
                            zatoshi: zec,
                            // swiftlint:disable:next force_try
                            toAddress: try! Recipient(flow.address, network: kPirateNetwork.networkType),
                            // swiftlint:disable:next force_try
                            memo: convertToMemo(aMemo: flow.memo)
                        )
                        
                        self.flow.isDone = true
                        
                        printLog("transaction created: \(pendingTransaction)")
                        
//                        self.flow.close()
//                        NotificationCenter.default.post(name: NSNotification.Name("DismissPasscodeScreenifVisible"), object: nil)

                    } catch {
                        self.flow.error = error
                        self.flow.showError = true
                        printLog("SEND FAILED: \(error)")
                    }
                }
            }
            
        
        }
    }
    
    func convertToMemo(aMemo:String) throws -> Memo {
        
        if aMemo.isEmpty == false{
            return try Memo(string: aMemo)
        }else{
            return .empty
        }
        
    }
}
