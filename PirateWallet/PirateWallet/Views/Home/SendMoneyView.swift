
//
//  SendMoneyView.swift
//  PirateWallet
//
//  Created by Lokesh on 28/11/24.
//

import SwiftUI
import PirateLightClientKit
import MnemonicSwift
import UIKit

struct SendMoneyView: View {
    
    @State var isSendTapped = false
    @EnvironmentObject var flow: SendFlowEnvironment
    @Environment(\.presentationMode) var presentationMode
    @State var homeViewModel: HomeViewModel
    @State var scanViewModel = ScanAddressViewModel(shouldShowSwitchButton: false, showCloseButton: true)
    @State var adjustTransaction = false
    @State var validateTransaction = false
    @State var validatePinBeforeInitiatingFlow = false
    let dragGesture = DragGesture()
  
    var availableBalance: Bool {
        return homeViewModel.verifiedBalance > 0
    }
        
    var charLimit: Int {
        if flow.includeSendingAddress {
         
            let derivationTool = DerivationTool(networkType: kPirateNetwork.networkType)
            if let spendingKey = try? derivationTool.deriveUnifiedSpendingKey(seed: PirateAppConfig.defaultSeed, accountIndex: 0) {
           
            // Seed
            let mnemonicSeedBytes = PirateAppConfig.defaultSeed
                
                let shieldedAddress = homeViewModel.arrrAddress
                return PirateAppConfig.memoLengthLimit - SendFlowEnvironment.replyToAddress(shieldedAddress ?? "").count
            }
        }
        return PirateAppConfig.memoLengthLimit
    }
    
    var validAddress: Bool {
        return DerivationTool(networkType: kPirateNetwork.networkType).isValidSaplingAddress(flow.address)
    }
    
    var sufficientAmount: Bool {
        let amount = (flow.doubleAmount ??  0 )
        return amount > 0 && amount <= Double(homeViewModel.verifiedBalance)
    }
    
    var isSendingAmountSameAsBalance:Bool{
        let amount = (flow.doubleAmount ??  0 )
        return amount > 0 && amount == Double(homeViewModel.verifiedBalance)
    }
    
    var validForm: Bool {
        availableBalance && validAddress && sufficientAmount && validMemo
    }
    
    var validMemo: Bool {
        flow.memo.count >= 0 && flow.memo.count <= charLimit
    }
    
    var addressSubtitle: String {
        guard !flow.address.isEmpty else {
            return "feedback_default".localized()
        }
        
        if flow.address.isValidShieldedAddress {
            return "feedback_shieldedaddress".localized()
        } else if flow.address.isValidTransparentAddress {
            return "feedback_transparentaddress".localized()
        }
//        else if (environment.getShieldedAddress() ?? "") == flow.address {
//            return "feedback_sameaddress".localized()
//        }
        else {
            return "feedback_invalidaddress".localized()
        }
    }
    
    var recipientActiveColor: Color {
        let address = flow.address
        if address.isValidShieldedAddress {
            return Color.arrrBlue
        } else {
            return Color.zGray2
        }
    }
    
    var body: some View {
        NavigationView {
        ZStack{
            ARRRBackground()
            VStack{
                
                ARRRActionableTextField(
                    title: "\("label_to".localized()):",
                    subtitleView: AnyView(
                        Text.subtitle(text: addressSubtitle)
                    ),
                    keyboardType: UIKeyboardType.alphabet,
                    binding: $flow.address,
                    action: {
                        printLog("sendAddressScan")
                        UIApplication.shared.endEditing()
                        self.flow.showScanView = true
                },
                    accessoryIcon: Image("QRCodeIcon")
                        .renderingMode(.original),
                    activeColor: recipientActiveColor,
                    onEditingChanged: { _ in },
                    onCommit: {
                        printLog("QR Code Tapped")
                }
                ).modifier(BackgroundPlaceholderModifierHome()).padding(.leading, 15).padding(.trailing, 15).padding(.top, 20)
                    .onReceive(scanViewModel.addressPublisher, perform: { (address) in
                        self.flow.address = address
                        self.flow.showScanView = false
                        DeviceFeedbackHelper.vibrate()
                    })
                    .sheet(isPresented: self.$flow.showScanView) {
                        NavigationView {
                            LazyView(
                                
                                ScanAddress(
                                    viewModel: self.scanViewModel,
                                    cameraAccess: CameraAccessHelper.authorizationStatus,
                                    isScanAddressShown: self.$flow.showScanView
                                )
                                
                            )
                        }
                }
                
                HStack{
                    Text("Memo".localized())
                        .scaledFont(size: Device.isLarge ? 20 : 12)
                        .foregroundColor(Color.textTitleColor)
                                    .frame(height: 22,alignment: .leading)
                                    .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .truncationMode(.middle).padding(.leading, 10)
                        .padding(10)
                    Spacer()
                }
                
                ARRRMemoTextField(memoText:self.$flow.memo).frame(height:Device.isLarge ? 45 : 30)
                
                HStack{
   
                    ARRRSendMoneyTextField(anAmount: self.$flow.amount)
                
                    SendMoneyButtonView(title: "Send Max".localized()) {
                        let actualAmount = Double((homeViewModel.verifiedBalance))
                        let defaultNetworkFee: Double = Int64(10_000).asHumanReadableZecBalance() // 0.0001 minor fee
                        if (actualAmount > defaultNetworkFee){
                            flow.amount = formatAnARRRAmount(arrr: actualAmount-defaultNetworkFee)
                        }else{
                            // Can't adjust the amount, as its less than the fee
                        }
                    }
                }
                
//               
//                HStack{
//                    Spacer()
//                    Text("Processing fee: ".localized() + "\(Int64(PirateSDKMainnetConstants.defaultFee()).asHumanReadableZecBalance().toZecAmount())" + " ARRR")
//                        .scaledFont(size: Device.isLarge ? 14 : 12).foregroundColor(Color.textTitleColor)
//                                    .frame(height: 22,alignment: .leading)
//                        .multilineTextAlignment(.leading)
//                        .truncationMode(.middle)
//                    Spacer()
//                }
                              
                Spacer()
                
                BlueButtonView(aTitle: "Send".localized()).onTapGesture {
                    
                    if isSendingAmountSameAsBalance {
                        // throw an alert here
                        adjustTransaction = true
                    }else{
                        validateTransaction = true
                        UIApplication.shared.endEditing()
                    }
                }.opacity(validForm ? 1.0 : 0.7 )
                .disabled(!validForm)
                
                
                
                
                NavigationLink(
                    destination: LazyView(
                        Sending().environmentObject(flow)
                            .navigationBarTitle("",displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                    ), isActive: self.$isSendTapped
                ) {
                    EmptyView()
                }
                
                
                
            }.onTapGesture {
                UIApplication.shared.endEditing()
            }
            .ARRRNavigationBar(leadingItem: {
                EmptyView()
             }, headerItem: {
                 HStack{
                     Text("Send Money".localized())
                         .font(.barlowRegular(size: Device.isLarge ? 22 : 14)).foregroundColor(Color.zSettingsSectionHeader)
                         .frame(alignment: Alignment.center).padding(.top,30)
                        
                 }
             }, trailingItem: {
                 ARRRCloseButton(action: {
                     self.onDismissRemoveObservers()
                     if #available(iOS 16.0, *) {
                         presentationMode.wrappedValue.dismiss()
                     }else{
                          if UIApplication.shared.windows.count > 0 {
                              UIApplication.shared.windows[0].rootViewController?.dismiss(animated: true, completion: nil)
                          }
                     }
                     
                     }).frame(width: 20, height: 20)
                 .padding(.top,40)
             })
            .navigationBarHidden(true)
        }
        .onTapGesture {
            UIApplication.shared.endEditing()
        }
        .highPriorityGesture(dragGesture)
        .sheet(isPresented: $validateTransaction) {
            LazyView(ConfirmTransaction(homeViewModel: homeViewModel).environmentObject(flow))
        }
        .sheet(isPresented: $validatePinBeforeInitiatingFlow) {
            LazyView(PasscodeValidationScreen(passcodeViewModel: PasscodeValidationViewModel(), isAuthenticationEnabled: false))
        }
        .alert(isPresented:self.$adjustTransaction) {
            Alert(title: Text("Pirate Chain Wallet".localized()),
                         message: Text("We found your wallet didn't had enough funds for the fees, the transaction needs to been adjusted to cater the fee of 0.0001 ARRR. Please, confirm the adjustment in the transaction to include miner fee.".localized()),
                         primaryButton: .cancel(Text("Cancel".localized())),
                         secondaryButton: .default(Text("Confirm".localized()), action: {
                            
                            let amount = (flow.doubleAmount ??  0 )
                            let defaultNetworkFee: Double = Int64(10_000).asHumanReadableZecBalance() // 0.0001 minor fee
                            if (amount > defaultNetworkFee && amount == Double(homeViewModel.verifiedBalance)){
                                flow.amount = formatAnARRRAmount(arrr: amount-defaultNetworkFee)
                                validateTransaction = true
                            }else{
                                // Can't adjust the amount, as its less than the fee
                            }
                         }))
        }
        .onAppear(){
            NotificationCenter.default.addObserver(forName: NSNotification.Name("PasscodeValidationSuccessful"), object: nil, queue: .main) { (_) in
                flow.includesMemo = true
                isSendTapped = true
            }
            NotificationCenter.default.addObserver(forName: NSNotification.Name("ConfirmedTransaction"), object: nil, queue: .main) { (_) in
                DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                    validatePinBeforeInitiatingFlow = true
                }
            }
        }
        .keyboardAdaptive()
        }
    }
    
    func onDismissRemoveObservers() {
        NotificationCenter.default.removeObserver(NSNotification.Name("PasscodeValidationSuccessful"))
        NotificationCenter.default.removeObserver(NSNotification.Name("ConfirmedTransaction"))
    }
    
    var includesMemo: Bool {
        !self.flow.memo.isEmpty || self.flow.includeSendingAddress
    }

}


func formatAnARRRAmount(arrr: Double) -> String {
    NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: arrr)) ?? "0"
}


//struct SendMoneyView_Previews: PreviewProvider {
//    static var previews: some View {
//        SendMoneyView()
//    }
//}

struct SendMoneyButtonView : View {
    
    @State var title: String
    
    var action: () -> Void
    
    var body: some View {
        ZStack{
            
            Image("buttonbackground").resizable().frame(width: 115)
       
                Text(title).foregroundColor(Color.zARRRTextColorLightYellow).bold().multilineTextAlignment(.center).font(
                    .barlowRegular(size: 12)
                ).onTapGesture {
                    self.action()
                }
                .modifier(ForegroundPlaceholderModifierHomeButtons())
                .frame(width: 140)
                .padding([.bottom],4)
                .cornerRadius(30)
           
        }.frame(width: 120,height:50)
    }
}


struct ARRRReceiveMoneyTextField: View {
    
     @Binding var anAmount:String
     var body: some View {
         ARRRTextFieldRepresentable(text: $anAmount,isFirstResponder: Binding.constant(false))
               .scaledFont(size: 22)
               .foregroundColor(.gray)
               .frame(height:30)
               .multilineTextAlignment(.center)
               .padding(.leading,10)
               .padding(.trailing,10)
               .keyboardType(.decimalPad)
               .modifier(BackgroundPlaceholderModifier())
         
         
     }
}

