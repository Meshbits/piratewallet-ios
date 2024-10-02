//
//  Home.swift
//  PirateWallet
//
//  Created by Lokesh on 29/09/24.
//


import SwiftUI
import Combine
import PirateLightClientKit
import LocalAuthentication
import AlertToast


struct Home: View {

    @Environment(\.currentTab) var mCurrentTab
    
    let buttonHeight: CGFloat = 64
    let buttonPadding: CGFloat = 40
    @State var sendingPushed = false
    @State var feedbackRating: Int? = nil
    @State var isOverlayShown = false
    @State var transparentBalancePushed = false
    @State var showPassCodeScreen = false
    @State var openProfileScreen = false
    
    
    @StateObject var viewModel: HomeViewModel

    @State var isAuthenticatedFlowInitiated = false
    @State var selectedModel: DetailModel? = nil
    @State var cantSendError = false
    
    @ViewBuilder func buttonFor(syncStatus: SyncStatus) -> some View {
        switch syncStatus {
        case .error:
            Button(action: {
                self.viewModel.retrySyncing()
            }, label: {
                Text("Error".localized())
                    .foregroundColor(.red)
                    .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .red, lineWidth: 2))).font(.barlowRegular(size: Device.isLarge ? 22 : 14))
            })
            
            
        case .unprepared:
            Text("Unprepared".localized())
                .foregroundColor(.red)
                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .outline(color: .zGray2, lineWidth: 2)))
            
//        case .downloading(let progress):
//            SyncingButton(animationType: .frameProgress(startFrame: 0, endFrame: 100, progress: 1.0, loop: true)) {
//                Text("Downloading".localized() + " \(Int(progress.progress * 100))%")
//                    .foregroundColor(.white).font(.barlowRegular(size: Device.isLarge ? 22 : 14))
//            }
//            .frame(width: 100, height: buttonHeight)
//            
//        case .validating:
//            Text("Validating".localized())
//                .font(.system(size: 15)).italic()
//                .foregroundColor(.black)
//                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .gradient(gradient: .zButtonGradient))).font(.barlowRegular(size: Device.isLarge ? 22 : 14))
        case .syncing(let scanProgress):
            SyncingButton(animationType: .frameProgress(startFrame: 101, endFrame: 187,  progress: scanProgress, loop: false)) {
                Text("Scanning".localized() + " \(Int(scanProgress * 100 ))%")
                    .foregroundColor(.white).font(.barlowRegular(size: Device.isLarge ? 22 : 14))
            }
            .frame(width: 100, height: buttonHeight)
//        case .enhancing(let enhanceProgress):
//            SyncingButton(animationType: .circularLoop) {
//                Text("Enhancing".localized() + " \(enhanceProgress.enhancedTransactions) of \(enhanceProgress.totalTransactions)")
//                    .foregroundColor(.white).font(.barlowRegular(size: Device.isLarge ? 22 : 14))
//            }
//            .frame(width: 100, height: buttonHeight)
            
//        case .fetching:
//            SyncingButton(animationType: .circularLoop) {
//                Text("Fetching".localized())
//                    .foregroundColor(.white).font(.barlowRegular(size: Device.isLarge ? 22 : 14))
//            }
//            .frame(width: 100, height: buttonHeight)
            
        case .unprepared:
            Button(action: {
                self.viewModel.retrySyncing()
            }, label: {
                Text("Stopped".localized())
                    .font(.system(size: 15)).italic()
                    .foregroundColor(.black)
                    .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: .zLightGray))).font(.barlowRegular(size: Device.isLarge ? 22 : 14))
            })
            
//        case .disconnected:
//            Button(action: {
//                self.viewModel.retrySyncing()
//            }, label: {
//                Text("Offline".localized())
//                    .font(.system(size: 15)).italic()
//                    .foregroundColor(.black)
//                    .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: .zLightGray))).font(.barlowRegular(size: Device.isLarge ? 22 : 14))
//            })
        case .upToDate:
            ZStack {
                NavigationLink(destination: EmptyView()) {
                    EmptyView()
                }
//                NavigationLink(
//                    destination: LazyView(
//                        SendTransaction()
//                            .environmentObject(
//                                SendFlow.current! //fixme
//                            )
//                            .navigationBarTitle("",displayMode: .inline)
//                            .navigationBarHidden(true)
//                    ), isActive: self.$sendingPushed
//                ) {
//                    EmptyView()
//                }
                
                self.enterAddressButton
                    .onReceive(self.viewModel.$sendingPushed) { pushed in
                        if pushed {
                            self.startSendFlow()
                        }
//                        else {
//                            self.endSendFlow()
//                        }
                    }
                    .disabled(!canSend)
                    .opacity(canSend ? 1 : 0.6)
            }
        }
    }
       
    var isSyncing: Bool {
        PirateAppSynchronizer.shared.synchronizer?.latestState.syncStatus.isSyncing ??  false
    }
    
    var isSendingEnabled: Bool {
        (PirateAppSynchronizer.shared.synchronizer?.latestState.syncStatus.isSynced ??  false) && self.viewModel.shieldedBalance.verified > 0
    }
    
    
    func startSendFlow(memo:String, address:String) {
        
        if isAmountValid {
           
            if(self.viewModel.syncStatus.isSynced){

//                SendFlow.start(appEnviroment: appEnvironment,
//                               isActive: self.$sendingPushed,
//                               amount: viewModel.sendZecAmount,memoText: memo,address:address)
                self.sendingPushed = true
                
                if self.sendingPushed {
                    self.viewModel.destination = .sendMoney
                }
            }else{
                cantSendError = true
            }
        }
        
    }
    
    func startSendFlow() {
//        SendFlow.start(appEnviroment: appEnvironment,
//                       isActive: self.$sendingPushed,
//                       amount: viewModel.sendZecAmount,memoText: "",address: "")
        self.sendingPushed = true
    }
    
    func endSendFlow() {
//        SendFlow.end()
        self.sendingPushed = false
    }
    
    var enterAddressButton: some View {
        Button(action: {
            self.startSendFlow()
        }) {
            Text("button_send".localized())
                .foregroundColor(.black)
                .zcashButtonBackground(shape: .roundedCorners(fillStyle: .solid(color: Color.zYellow)))
                .font(.barlowRegular(size: Device.isLarge ? 22 : 14))
        }
    }
    
    var isAmountValid: Bool {
        self.viewModel.sendZecAmount > 0 && self.viewModel.sendZecAmount < self.viewModel.shieldedBalance.verified
        
    }
    
    var canSend: Bool {
        isSendingEnabled && isAmountValid
    }
    @ViewBuilder func balanceView(shieldedBalance: ReadableBalance, transparentBalance: ReadableBalance) -> some View {
        if shieldedBalance.isThereAnyBalance || transparentBalance.isThereAnyBalance {
//            BalanceDetail(availableZec: shieldedBalance.verified,
//                          transparentFundsAvailable: transparentBalance.isThereAnyBalance,
//                          status: appEnvironment.balanceStatus)
        } else {
            ARRRActionableMessage(message: "balance_nofunds".localized())
        }
    }
    
    var walletDetails: some View {
        Button(action: {
            self.viewModel.pushDestination = .history
        }, label: {
            Text("button_wallethistory".localized())
                .foregroundColor(.white)
                .font(.barlowRegular(size: Device.isLarge ? 16 : 10))
                .opacity(0.6)
                .frame(height: 48)
        })
    }
    
    var amountOpacity: Double {
        self.isSendingEnabled ? self.viewModel.sendZecAmount > 0 ? 1.0 : 0.6 : 0.3
    }
    
    func getFirstNModels() -> [DetailModel]{
        
        if self.viewModel.getSortedItems().count > 5 {
            return Array(self.viewModel.getSortedItems()[..<5])
        }else{
            return self.viewModel.getSortedItems()
        }
    }
       
    var body: some View {

        ZStack {
            ARRRBackground().edgesIgnoringSafeArea(.all)

/*
        ZStack {
            NavigationLink(
                destination: WalletBalanceBreakdown()
                    .environmentObject(ModelFlyWeight.shared.modelBy(defaultValue: WalletBalanceBreakdownViewModel())),
                tag: HomeViewModel.PushDestination.balance,
                selection: $viewModel.pushDestination,
                label: { EmptyView()} )
            
            
            NavigationLink(
                destination:
                    LazyView(WalletDetails(viewModel: WalletDetailsViewModel(),
                                           isActive: self.$viewModel.showHistory)
                                .navigationBarTitle(Text(""), displayMode: .inline)
                                .navigationBarHidden(true)),
                tag: HomeViewModel.PushDestination.history,
                selection: $viewModel.pushDestination,
                label: { EmptyView() })
                .isDetailLink(false)
            
            NavigationLink(
                destination: EmptyView(),
                label: {
                    EmptyView()
                })
*/
            
            GeometryReader { geo in
               VStack(alignment: .center, spacing: 5) {
                
                   HStack {
                       Spacer()
                       BalanceViewHome(availableARRR: 2.0, status: BalanceStatus.available(showCaption: false), aTitleStatus: viewModel.aSyncTitleStatus ?? "")
                   }
                   .padding(.bottom,10)
                

                       .frame(height: Device.isLarge ? 64 : 44)
                .padding([.leading, .trailing], 10)
                .padding(.top,40)
                
//                SendZecView(zatoshi: self.$viewModel.sendZecAmountText)
//                    .opacity(amountOpacity)
//                    .scaledToFit()
//
//                if self.isSyncing {
//                    self.balanceView(
//                        shieldedBalance: self.viewModel.shieldedBalance,
//                        transparentBalance: self.viewModel.transparentBalance)
//                        .padding([.horizontal], self.buttonPadding)
//                } else {
//                    NavigationLink(
//                        destination: WalletBalanceBreakdown()
//                                        .environmentObject(WalletBalanceBreakdownViewModel()),
//                        isActive: $transparentBalancePushed,
//                        label: {
//                            self.balanceView(
//                                shieldedBalance: self.viewModel.shieldedBalance,
//                                transparentBalance: self.viewModel.transparentBalance)
//                                .padding([.horizontal], self.buttonPadding)
//                        })
//                }
                
                if self.viewModel.getSortedItems().count > 0 {
                    
                    Text("Recent Transfers".localized())
                        .multilineTextAlignment(.leading)
                        .font(.barlowRegular(size: Device.isLarge ? 20 : 13)).foregroundColor(Color.zSettingsSectionHeader)
                        .frame(maxWidth: .infinity,alignment: Alignment.leading).padding(Device.isLarge ? 10 : 5).padding(.leading, 10)
                        .padding(.top, Device.isLarge ? 20 : 5)
                    
                    List {
                        
                        // Show recent transactions in here
                        // Max 5 recent transactions will be pulled here on the UI
                        ForEach(getFirstNModels()) { row in
                            Button(action: {
                                self.selectedModel = row
                            }) {
                                DetailCard(model: row, backgroundColor: .zDarkGray2,isFromWalletDetails:false)
                            }
                            .listRowBackground(ARRRBackground())
                            .frame(height: Device.isLarge ? 69 : 49)
                            .cornerRadius(0)
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                              
                       }
                        
                    }
                    .listStyle(PlainListStyle())
                    .modifier(BackgroundPlaceholderModifierHome())
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.zGray, lineWidth: 1.0)
                    )
                    .padding()
                }else{
                    Spacer()
                    Text("No Recent Transfers").font(.barlowRegular(size: Device.isLarge ? 30 : 20)).foregroundColor(Color.zSettingsSectionHeader)
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                
                
//                KeyPad(value: $viewModel.sendZecAmountText)
//                    .frame(alignment: .center)
//                    .padding(.horizontal, buttonPadding)
//                    .opacity(self.isSendingEnabled ? 1.0 : 0.3)
//                    .disabled(!self.isSendingEnabled)
//                    .alert(isPresented: self.$viewModel.showError) {
//                        self.viewModel.errorAlert
//                }
                
                HStack(alignment: .center, spacing: 2, content: {
                    
                    SendRecieveButtonView(title: "Receive".localized(),isSyncing:Binding.constant(false)).onTapGesture {
                        self.viewModel.destination = .receiveFunds
                    }
                    
                    SendRecieveButtonView(title: "Send".localized(),isSyncing:$viewModel.isSyncing)
                        .onTapGesture {
                            cantSendError = false
                            // Send tapped
                            if(self.viewModel.syncStatus.isSynced){
                                self.startSendFlow()
                                
                                if self.sendingPushed {
                                    self.viewModel.destination = .sendMoney
                                }
                            }else{
                                cantSendError = true
                            }
                        }
                        .onReceive(self.viewModel.$sendingPushed) { pushed in
                        if pushed {
                            self.startSendFlow()
                        } else {
                            self.endSendFlow()
                        }
                    }
                })
                .frame(maxWidth:.infinity)
                .padding()
                
                
//                NavigationLink(
//                    destination: LazyView(
//                        SendTransaction()
//                            .environmentObject(
//                                SendFlow.current! //fixme
//                        )
//                            .navigationBarTitle("",displayMode: .inline)
//                            .navigationBarHidden(true)
//                    ), isActive: self.$sendingPushed
//                ) {
//                    EmptyView()
//                }.isDetailLink(false)
                
                
//                NavigationLink(
//                    destination: LazyView(
//                        SendMoneyView()
//                            .environmentObject(
//                                SendFlow.current! //fixme
//                        )
//                            .navigationBarTitle("",displayMode: .inline)
//                            .navigationBarHidden(true)
//                    ), isActive: self.$sendingPushed
//                ) {
//                    EmptyView()
//                }.isDetailLink(false)
                
                
                
//                buttonFor(syncStatus: self.viewModel.syncStatus)
//                    .frame(height: self.buttonHeight)
//                    .padding(.horizontal, buttonPadding)
              
                
//                NavigationLink(
//                    destination:
//                        LazyView(WalletDetails(isActive: self.$viewModel.showHistory)
//                        .environmentObject(WalletDetailsViewModel())
//                        .navigationBarTitle(Text(""), displayMode: .inline)
//                        .navigationBarHidden(true))
//                    ,isActive: self.$viewModel.showHistory) {
//                    walletDetails
//                } /*.isDetailLink(false)*/
//                    .opacity(viewModel.isSyncing ? 0.4 : 1.0)
//                    .disabled(viewModel.isSyncing)
            }
            .padding([.bottom],  Device.isLarge ? 20 : 10)
          }

        }
        .toast(isPresenting: $cantSendError){

            AlertToast(displayMode: .hud, type: .regular, title:"Please wait, ARRR Wallet Syncing is in progress.".localized())

        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
          
            if AppDelegate.isTouchIDVisible {
//                print("AppDelegate.isTouchIDVisible: \(AppDelegate.isTouchIDVisible)")
                return
            }else{
                             
                if UIApplication.shared.windows.count > 0 {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: false, completion: nil)
                }
                                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    self.showPassCodeScreen = true
                    print("showPassCodeScreen: \(showPassCodeScreen)")
                }
            }

            
//            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//                authenticate()
//            }
            
        }.onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
                        
            if AppDelegate.isTouchIDVisible {
                print("AppDelegate.isTouchIDVisible: \(AppDelegate.isTouchIDVisible)")
                return
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    self.showPassCodeScreen = false
                    print("showPassCodeScreen: \(showPassCodeScreen)")
                }
                
                if UIApplication.shared.windows.count > 0 {
                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: false, completion: nil)
                }
            }
        }
//        .onReceive(AuthenticationHelper.authenticationPublisher) { (output) in
//                   switch output {
//                   case .failed(_), .userFailed:
////                       print("SOME ERROR OCCURRED")
//                        UserSettings.shared.isBiometricDisabled = true
//                        NotificationCenter.default.post(name: NSNotification.Name("BioMetricStatusUpdated"), object: nil)
//
//                   case .success:
////                        print("SUCCESS ON HOME")
//
//                        if mCurrentTab == HomeTabView.Tab.home {
//                            UserSettings.shared.biometricInAppStatus = true
//                            UserSettings.shared.isBiometricDisabled = false
//                            self.showPassCodeScreen = false
////                            NotificationCenter.default.post(name: NSNotification.Name("DismissPasscodeScreenifVisible"), object: nil)
//                        }
//
//                   case .userDeclined:
////                       print("DECLINED")
//                        UserSettings.shared.biometricInAppStatus = false
//                        UserSettings.shared.isBiometricDisabled = true
//                        NotificationCenter.default.post(name: NSNotification.Name("BioMetricStatusUpdated"), object: nil)
//                       break
//                   }
//
//
//       }
        .onReceive(NotificationCenter.default.publisher(for: .openTransactionScreen)) { notificationObject in
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            initiateDeeplinkDirectSendFlow(notificationObject: notificationObject)
        }
       }
        .sheet(item: self.$viewModel.destination, onDismiss: nil) { item  in
//            switch item {
//            case .profile:
//                ProfileScreen()
//                    .environmentObject(self.appEnvironment)
//            case .receiveFunds:
//                ReceiveFunds(unifiedAddress: self.appEnvironment.synchronizer.unifiedAddress,qrImage:self.viewModel.qrCodeImage)
//                    .environmentObject(self.appEnvironment)
//            case .feedback(let score):
//                #if ENABLE_LOGGING
//                FeedbackForm(selectedRating: score,
//                             isSolicited: true,
//                             isActive: self.$viewModel.destination)
//                #else
//                ProfileScreen()
//                    .environmentObject(self.appEnvironment)
//                #endif
//            case .sendMoney:
//                
//                if let sendflowCurrent = SendFlow.current{
//                    SendMoneyView()
//                        .environmentObject(
//                            sendflowCurrent
//                    )
//                }
//                
//               
//            }
        }
              
        .sheet(isPresented: $showPassCodeScreen){
//            LazyView(PasscodeValidationScreen(passcodeViewModel: PasscodeValidationViewModel(), isAuthenticationEnabled: true)).environmentObject(self.appEnvironment)
        }
        .toast(isPresenting: $viewModel.showLowSpaceAlert, duration: 10, tapToDismiss: true, alert: {
            AlertToast(displayMode: .alert,type: .error(.red), title:"Low storage space".localized())
        }, onTap: {
            //onTap would call either if `tapToDismis` is true/false
            //If tapToDismiss is true, onTap would call and then dismis the alert
         }, completion: {
            //Completion block after dismiss
         })
        .onAppear {
            showFeedbackIfNeeded()
            let freeSpace = DiskStatus.freeDiskSpaceInBytes
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                if freeSpace <= 200000000 {
                    viewModel.showLowSpaceAlert.toggle()
                }
            }
           

        }

        .navigationBarBackButtonHidden(true)
        .navigationBarTitle("", displayMode: .inline)
        .navigationBarHidden(true)
        .edgesIgnoringSafeArea([.top])
        .zOverlay(isOverlayShown: $viewModel.isOverlayShown) {
            feedbackOrNotice()
        }.sheet(item: self.$selectedModel, onDismiss: {
            self.selectedModel = nil
        }) { (row)  in
            TxDetailsWrapper(row: row)
        }
    }
    
    @ViewBuilder func feedbackOrNotice() -> some View {
        switch viewModel.overlayType {
        case .feedback:
            FeedbackDialog(rating: $feedbackRating) { feedbackResult in
                self.viewModel.isOverlayShown = false
                switch feedbackResult {
                case .score(let rating):
                    printLog("rating here")
                case .requestAdditional(let rating):
                    self.viewModel.destination = .feedback(score: rating)
                }
                
            }
            .frame(height: 240)
            .padding(.horizontal, 24)
        case .autoShielding:
            Text("AUTO SHIELD VIEW") // TODO LS
//            AutoShieldView(isPresented: self.$viewModel.isOverlayShown)
//                
//                .environmentObject(ModelFlyWeight.shared.modelBy(defaultValue: AutoShieldingViewModel(shielder: self.appEnvironment.autoShielder)))
        case .shieldNowDialog:
            ShieldNowDialog {
                self.viewModel.overlayType = .autoShielding
            } dismissBlock: {
                self.viewModel.isOverlayShown = false
                self.viewModel.overlayType = nil
//                Session.unique.markAutoShield()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 100)
        default:
            Text("AUTO SHEILDING NOTICE VIEW") // TODO LS
//            AutoShieldingNotice {
//                tracker.track(.tap(action: .acceptAutoShieldNotice), properties: [:])
//                
//                self.appEnvironment.registerAutoShieldingNoticeScreenShown()
//                
//                if appEnvironment.autoShielder.strategy.shouldAutoShield {
//                    self.viewModel.overlayType = .autoShielding
//                } else {
//                    self.viewModel.isOverlayShown = false
//                }
//            }
        }
       
    }
    
    
    func authenticate() {
//        if UserSettings.shared.biometricInAppStatus && !isAuthenticatedFlowInitiated{
//            isAuthenticatedFlowInitiated = true
//            AuthenticationHelper.authenticate(with: "Authenticate Biometric".localized())
//            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//                isAuthenticatedFlowInitiated = false
//            }
//        }
    }

    
    func initiateDeeplinkDirectSendFlow(notificationObject:Notification){
        
        if let userInfo = notificationObject.userInfo, let url:URL = userInfo["url"] as? URL {
            
            guard let aReplyAddress = url.host else {
                printLog("Invalid Reply Address, can't proceed")
                return
            }
            
            guard PirateAppSynchronizer.shared.synchronizer!.initializer.isValidSaplingAddress(aReplyAddress) else {
                printLog("Invalid Sheilded Address, can't proceed")
                return
            }

            let queryComponents = url.getQueryParameters
            
            var amountValue = 0.0
            
            if let amount = queryComponents["amount"] {
                amountValue = Double(amount)!
            }
            
            if let amount = queryComponents["tx_amount"] {
                amountValue = Double(amount)!
            }
            
            var mMemoMessage = ""
            
            if let memoMessage = queryComponents["message"] {
                mMemoMessage = memoMessage
            }
                        
            if let memoMessage = queryComponents["msg"] {
                mMemoMessage = memoMessage
            }

            self.viewModel.setAmountWithoutFee(amountValue)
            
            if self.viewModel.isSyncing == false{
                printLog("Syncing is not in progress, please proceed to transaction screen")
                
                let memoMessageDecoded = mMemoMessage.removingPercentEncoding
                
                self.startSendFlow(memo: memoMessageDecoded ?? "",address: aReplyAddress ?? "")
                
                
            }else{
                printLog("Syncing is in progress, can't proceed")
            }
        }
     
        
    }

}

extension BlockHeight {
    static var unmined: BlockHeight {
        -1
    }
}


extension Home {
    func showFeedbackIfNeeded() {
        #if ENABLE_LOGGING
        if !appEnvironment.shouldShowAutoShieldingNotice && appEnvironment.shouldShowFeedbackDialog {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                appEnvironment.registerFeedbackSolicitation(on: Date())
                self.viewModel.isOverlayShown = true
                self.viewModel.overlayType = .feedback
            }
        }
        #endif
    }
}


struct SendRecieveButtonView : View {
    
    @State var title: String
    @Binding var isSyncing:Bool
    
    var body: some View {
        ZStack {
            Text(title).foregroundColor(isSyncing ? Color.zTextLightGray : Color.arrrBarAccentColor).bold().multilineTextAlignment(.center).font(
                .barlowRegular(size: Device.isLarge ? 22 : 15)
            ).modifier(ForegroundPlaceholderModifierHomeButtons())
            .padding([.bottom],8).foregroundColor(Color.init(red: 132/255, green: 124/255, blue: 115/255))
            .cornerRadius(Device.isLarge ? 30 : 15)
            .disabled(isSyncing)
            .background(Image("buttonbackground").resizable().opacity(isSyncing ? 0.6 : 1.0))
        }
    }
}

extension ReadableBalance {
    var isThereAnyBalance: Bool {
        verified > 0 || total > 0
    }
    
    var isSpendable: Bool {
        verified > 0
    }
}


struct BackgroundPlaceholderModifierHome: ViewModifier {

var backgroundColor = Color(.systemBackground)

func body(content: Content) -> some View {
    content
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12).fill(Color.init(red: 29.0/255.0, green: 32.0/255.0, blue: 34.0/255.0))
                .softInnerShadow(RoundedRectangle(cornerRadius: 12), darkShadow: Color.init(red: 0.06, green: 0.07, blue: 0.07), lightShadow: Color.init(red: 0.26, green: 0.27, blue: 0.3), spread: 0.05, radius: 2))
        
    }
}


