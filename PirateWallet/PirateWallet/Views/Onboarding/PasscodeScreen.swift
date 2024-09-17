//
//  PasscodeScreen.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import SwiftUI
import AlertToast
import LocalAuthentication

struct PasscodeScreen: View {
    
   @ObservedObject var passcodeViewModel = PasscodeViewModel()
    
    @State var openHomeScreen = false
    @State var initiateNewWalletPhraseSetup = false
    
    enum Destinations: Int {
        case createNew
        case restoreWallet
    }
    
    enum AlertType: Identifiable {
        case feedback(destination: Destinations, cause: Error)
        case error(cause:Error)
        var id: Int {
            switch self {
            case .error:
                return 0
            case .feedback:
                return 1
            }
        }
    }
    
    
    enum PasscodeScreenStates: Int {
        case none = 0
        case validatePasscode = 1
        case newPasscode = 2
        case confirmPasscode = 3
        case passcodeAlreadyExists = 4
        case changePasscode = 5
        case validateAndDismiss = 6
    }

    
//    @Environment(\.walletEnvironment) var appEnvironment: ZECCWalletEnvironment
    
    @Environment(\.presentationMode) var presentationMode:Binding<PresentationMode>
      
//    @State var error: UserFacingErrors?
    @State var showError: AlertType?
    @State var destination: Destinations?
    @State private var showErrorToast = false
    @State private var showPasscodeChangeSuccessToast = false

    let dragGesture = DragGesture()
   
   @State var mScreenState: PasscodeScreenStates?
    
   @State var isNewWallet = false
    
   @State var isAuthenticatedFlowInitiated = false
    
   @State var isFirstTimeSetup = false
    
   @State var isChangePinFlow = false
    
   @State var isAllowedToPop = false
       
    var body: some View {
        ZStack {
            
//            NavigationLink(destination:
//                LazyView (
//                    BackupWallet().environmentObject(self.appEnvironment)
//                    .navigationBarHidden(true)
//                ),
//                           tag: Destinations.createNew,
//                           selection: $destination
//
//            ) {
//              EmptyView()
//            }
            
            
//            
//            NavigationLink(destination:
//                    GenerateKeyPhraseInitiate().environmentObject(self.appEnvironment)
//                    .navigationBarTitle("", displayMode: .inline)
//                    .navigationBarBackButtonHidden(true)
//                ,isActive: $initiateNewWalletPhraseSetup
//            ) {
//                EmptyView()
//            }.isDetailLink(false)
//            
            
            PasscodeBackgroundView()
            
            VStack(alignment: .center, spacing: 10, content: {
               
                HStack{
                    Spacer()
                    ARRRCloseButton(action: {
                        presentationMode.wrappedValue.dismiss()
                    })
                    .hidden(isChangePinFlow ? false : true) // unhide when its a change pin flow otherwise keep it hidden
                    .frame(width: 30, height: 30).padding(.top,30).multilineTextAlignment(.trailing)
                    .padding(.trailing,30)
                    
                }
//
//                HStack{
//
//                    ARRRBackButton(action: {
//                        presentationMode.wrappedValue.dismiss()
//                    }).frame(width: 30, height: 30)
//                    .hidden(!isAllowedToPop) // unhide when its a change pin flow otherwise keep it hidden
//                    .padding(.top,30).multilineTextAlignment(.leading)
//                    .padding(.leading,30)
//                    Spacer()
//                }
                
                
                if mScreenState == .passcodeAlreadyExists{
                    PasscodeScreenTopImageView().padding(.leading,20).padding(.top,50)
                }else if mScreenState == PasscodeScreenStates.validatePasscode{
                    PasscodeScreenTitle(aTitle: "LOGIN PIN".localized())
                    Spacer()
                    PasscodeScreenSubTitle(aSubTitle: "Enter PIN".localized())
                    PasscodeScreenDescription(aDescription: "Please enter your PIN to unlock your Pirate wallet and send money".localized(),size:Device.isLarge ? 12 : 10,padding:50)
                    Spacer()
                }else if mScreenState == .validateAndDismiss{
                    PasscodeScreenTitle(aTitle: "Enter PIN".localized())
                    Spacer()
                    PasscodeScreenSubTitle(aSubTitle: "PIN Required".localized())
                    PasscodeScreenDescription(aDescription: "Please enter your PIN to continue".localized(),size:Device.isLarge ? 12 : 10,padding:50)
                    Spacer()
                }else if mScreenState == .newPasscode{
                    PasscodeScreenTitle(aTitle: "Change PIN".localized())
                    Spacer()
                    PasscodeScreenSubTitle(aSubTitle: "SET PIN".localized())
                    PasscodeScreenDescription(aDescription: "Your PIN will be used to unlock your Pirate wallet and send money".localized(),size:Device.isLarge ? 12 : 10,padding:50)
                    Spacer()
                }else if mScreenState == .confirmPasscode{
                    PasscodeScreenTitle(aTitle: "Change PIN".localized())
                    Spacer()
                    PasscodeScreenSubTitle(aSubTitle: "Re-Enter PIN".localized())
                    PasscodeScreenDescription(aDescription: "Your PIN will be used to unlock your Pirate wallet and send money".localized(),size:Device.isLarge ? 12 : 10,padding:50)
                    Spacer()
                }else if mScreenState == .changePasscode{
                    PasscodeScreenTitle(aTitle: "Change PIN".localized())
                    Spacer()
                    PasscodeScreenSubTitle(aSubTitle: "Enter Current PIN".localized())
                    PasscodeScreenDescription(aDescription: "Your PIN will be used to unlock your Pirate wallet and send money".localized(),size:Device.isLarge ? 12 : 10,padding:50)
                    Spacer()
                }
                
                HStack(alignment: .center, spacing: 0, content: {
                    
                    ForEach(0 ..< passcodeViewModel.mStateOfPins.count) { index in
                        PasscodePinImageView(isSelected: Binding.constant(passcodeViewModel.mStateOfPins[index]))
                    }
                }).padding(.leading,20).padding(.trailing,20)

                PasscodeScreenDescription(aDescription: "Remember your PIN. If you forget it, you won't be able to access your assets.".localized(),size:Device.isLarge ? 14 : 8,padding:50)
                
                PasscodeNumberView(passcodeViewModel: Binding.constant(passcodeViewModel))
                
                Spacer(minLength: 10)
                                
            })
            .padding(.bottom, 20)
            
//            NavigationLink(destination:
//                            HomeTabView(openPasscodeScreen: false)
//                                .environmentObject(appEnvironment)
//                            .navigationBarTitle("", displayMode: .inline)
//                            .navigationBarBackButtonHidden(true)
//                            .navigationBarHidden(true)
//            , isActive: $openHomeScreen) {
//                EmptyView()
//            }.isDetailLink(false)
            
        }
        .highPriorityGesture(dragGesture)
        .onDisappear{
            NotificationCenter.default.removeObserver(NSNotification.Name("UpdateLayout"))
            NotificationCenter.default.removeObserver(NSNotification.Name("UpdateErrorLayout"))
            NotificationCenter.default.removeObserver(NSNotification.Name("UpdateChangeCodeErrorLayout"))
            
        }
        .onAppear {
            NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdateLayout"), object: nil, queue: .main) { (_) in
                
                if let aPasscode = UserSettings.shared.aPasscode, !aPasscode.isEmpty{
                    
                    let aTempPasscode = passcodeViewModel.changePinFlowInitiated ? passcodeViewModel.aTempChangeConfirmPasscode : passcodeViewModel.aTempPasscode
                    
                    if !aTempPasscode.isEmpty && aTempPasscode == aPasscode{
                        
                        if handleUseCasesRelatedToScreenStates() {
                            return
                        }
                        
                        if isNewWallet {
                            // Initiate Create New Wallet flow from here
//                            createNewWalletFlow()
                            initiateNewWalletPhraseSetup = true
                            return
                        }else{

                            if (!isFirstTimeSetup){
                                if UIApplication.shared.windows.count > 0 {
                                    UIApplication.shared.windows[0].rootViewController?.dismiss(animated: false, completion: nil)
                                }
                            }
                            
                            if (isChangePinFlow){
                                showPasscodeChangeSuccessToast = true
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    presentationMode.wrappedValue.dismiss()
                                }
                                // handle use case when change pin code is started with a wrong passcode and add a cross button
                                return
                            }
                            
                            openHomeScreen = true

                            return
                        }
                    }else{
                        
                        if (mScreenState == .changePasscode){
                            NotificationCenter.default.post(name: NSNotification.Name("UpdateChangeCodeErrorLayout"), object: nil)
                            return
                        }else{
                            if (!isChangePinFlow){
                                NotificationCenter.default.post(name: NSNotification.Name("UpdateErrorLayout"), object: nil)
                            }
                        }
                        
                       
                    }
                }
                
                if mScreenState == .newPasscode {
                    mScreenState = .confirmPasscode
                    passcodeViewModel.mStateOfPins = passcodeViewModel.mStateOfPins.map { _ in false }
                    passcodeViewModel.mPressedKeys.removeAll()
                }
                
                if mScreenState == .changePasscode {
                    isChangePinFlow = true
                    mScreenState = .newPasscode
                }
            }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdateErrorLayout"), object: nil, queue: .main) { (_) in
                showErrorToast = true
                DeviceFeedbackHelper.longVibrate()
                if mScreenState == .validatePasscode{
                    passcodeViewModel.aTempPasscode = ""
                }
                passcodeViewModel.mStateOfPins = passcodeViewModel.mStateOfPins.map { _ in false }
                passcodeViewModel.mPressedKeys.removeAll()
            }
            
            NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdateChangeCodeErrorLayout"), object: nil, queue: .main) { (_) in
                showErrorToast = true
                DeviceFeedbackHelper.longVibrate()
                passcodeViewModel.aTempPasscode = ""
                passcodeViewModel.mStateOfPins = passcodeViewModel.mStateOfPins.map { _ in false }
                passcodeViewModel.mPressedKeys.removeAll()
            }
            
            if mScreenState != .changePasscode && mScreenState != .validateAndDismiss{
                authenticate()
            }

        }
        .toast(isPresenting: $showErrorToast){

            AlertToast(displayMode: .hud, type: .error(.red), title:"Invalid passcode!".localized())

        }
        .toast(isPresenting: $showPasscodeChangeSuccessToast){

            AlertToast(displayMode: .hud, type: .complete(.green), title:"Passcode changed successfully!".localized())

        }
        .onReceive(AuthenticationHelper.authenticationPublisher) { (output) in
                   switch output {
                   case .failed(_), .userFailed:
                       print("SOME ERROR OCCURRED")
                        UserSettings.shared.isBiometricDisabled = true
                        NotificationCenter.default.post(name: NSNotification.Name("BioMetricStatusUpdated"), object: nil)

                   case .success:
                       print("SUCCESS IN PASSCODE")
                        UserSettings.shared.biometricInAppStatus = true
                        UserSettings.shared.isBiometricDisabled = false
                        if mScreenState == PasscodeScreenStates.validatePasscode {
                            openHomeScreen = true
                            NotificationCenter.default.post(name: NSNotification.Name("DismissPasscodeScreenifVisible"), object: nil)
                        }else{
                            // Handle other use case here
                            if handleUseCasesRelatedToScreenStates() {
                                return
                            }
                        }
                   case .userDeclined:
                       print("DECLINED")
                        UserSettings.shared.biometricInAppStatus = false
                        UserSettings.shared.isBiometricDisabled = true
                        NotificationCenter.default.post(name: NSNotification.Name("BioMetricStatusUpdated"), object: nil)
                       break
                   }
            

       }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
//            .alert(item: self.$showError) { (alertType) -> Alert in
//                switch alertType {
//                case .error(let cause):
//                    let userFacingError = mapToUserFacingError(ZECCWalletEnvironment.mapError(error: cause))
//                    return Alert(title: Text(userFacingError.title),
//                                 message: Text(userFacingError.message),
//                                 dismissButton: .default(Text("button_close".localized())))
//                case .feedback(let destination, let cause):
//                    if let feedbackCause = cause as? SeedManager.SeedManagerError,
//                       case SeedManager.SeedManagerError.alreadyImported = feedbackCause {
//                        return existingCredentialsFound(originalDestination: destination)
//                    } else {
//                        return defaultAlert(cause)
//                    }
//
//                }
//            }
    }
    
    func handleUseCasesRelatedToScreenStates()->Bool{
        
        var isReturnFromFlow = false
        
        switch mScreenState {
            case .validateAndDismiss:
                presentationMode.wrappedValue.dismiss()
                mScreenState = .validateAndDismiss
                NotificationCenter.default.post(name: NSNotification.Name("ValidationSuccessful"), object: nil)
                isReturnFromFlow = true
                break
            case .changePasscode:
                self.mScreenState = .newPasscode
                isReturnFromFlow = true
                self.passcodeViewModel.changePinFlowInitiated = true
                self.passcodeViewModel.aSavedPasscode = ""
                self.passcodeViewModel.aTempConfirmPasscode = ""
                self.passcodeViewModel.aTempPasscode = ""
                self.passcodeViewModel.mStateOfPins = passcodeViewModel.mStateOfPins.map { _ in false }
                self.passcodeViewModel.mPressedKeys.removeAll()
                break
            default:
                print("Default case")
        }
        
        return isReturnFromFlow
    }
    
    func createNewWalletFlow(){
//        do {
//            tracker.track(.tap(action: .landingBackupWallet), properties: [:])
//            try self.appEnvironment.createNewWallet()
//            openHomeScreen = true
//        } catch WalletError.createFailed(let e) {
//            if case SeedManager.SeedManagerError.alreadyImported = e {
//                self.showError = AlertType.feedback(destination: .createNew, cause: e)
//            } else {
//                fail(WalletError.createFailed(underlying: e))
//            }
//        } catch {
//            fail(error)
//        }
    }
    
    func fail(_ error: Error) {
//        let message = "could not create new wallet:".localized()
//        logger.error("\(message) \(error)")
//        tracker.track(.error(severity: .critical),
//                      properties: [
//                        ErrorSeverity.messageKey : message,
//                        ErrorSeverity.underlyingError : "\(error)"
//                        ])
//       
//       self.showError = .error(cause: mapToUserFacingError(ZECCWalletEnvironment.mapError(error: error)))
        
    }
    
//    func existingCredentialsFound(originalDestination: Destinations) -> Alert {
//        Alert(title: Text("Existing keys found!".localized()),
//              message: Text("it appears that this device already has keys stored on it. What do you want to do?".localized()),
//              primaryButton: .default(Text("Restore existing keys".localized()),
//                                      action: {
//                                        do {
//                                            try ZECCWalletEnvironment.shared.initialize()
//                                            self.destination = .createNew
//                                        } catch {
//                                            DispatchQueue.main.async {
//                                                self.fail(error)
//                                            }
//                                        }
//                                      }),
//              secondaryButton: .destructive(Text("Discard them and continue".localized()),
//                                            action: {
//                                                
//                                                ZECCWalletEnvironment.shared.nuke(abortApplication: false)
//                                                do {
//                                                    try ZECCWalletEnvironment.shared.reset()
//                                                } catch {
//                                                    self.fail(error)
//                                                    return
//                                                }
//                                                switch originalDestination {
//                                                case .createNew:
//                                                    do {
//                                                        try self.appEnvironment.createNewWallet()
//                                                        self.destination = originalDestination
//                                                    } catch {
//                                                            self.fail(error)
//                                                    }
//                                                case .restoreWallet:
//                                                    self.destination = originalDestination
//                                                
//                                                }
//                                            }))
//    }
    
    
//    func defaultAlert(_ error: Error? = nil) -> Alert {
//        guard let e = error else {
//            return Alert(title: Text("Error Initializing Wallet".localized()),
//                 message: Text("There was a problem initializing the wallet".localized()),
//                 dismissButton: .default(Text("button_close".localized())))
//        }
        
//        return Alert(title: Text("Error".localized()),
//                     message: Text(mapToUserFacingError(ZECCWalletEnvironment.mapError(error: e)).message),
//                     dismissButton: .default(Text("button_close".localized())))
        
//    }
    
    func authenticate() {
        if UserSettings.shared.biometricInAppStatus && mScreenState != .newPasscode && !isAuthenticatedFlowInitiated{
            isAuthenticatedFlowInitiated = true
            AuthenticationHelper.authenticate(with: "Authenticate Biometric ID".localized())
        }
    }
}
