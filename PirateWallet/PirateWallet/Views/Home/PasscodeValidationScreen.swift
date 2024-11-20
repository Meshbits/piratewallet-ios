//
//  PasscodeValidationScreen.swift
//  PirateWallet
//
//  Created by Lokesh on 20/11/24.
//

import SwiftUI
import AlertToast
import Combine
import LocalAuthentication

public class PasscodeValidationViewModel: ObservableObject{
    
    @Published var mStateOfPins: [Bool] = [false,false,false,false,false,false] // To change the color of pins
    
    @Published var mPressedKeys: [Int] = [] // To keep the pressed content
    
    @Published var mPasscodeValidationFailure = false
    
    @Published var mDismissAfterValidation = false
    
    var aTempPasscode = ""
        
    var aSavedPasscode = UserSettings.shared.aPasscode

    var cancellable: AnyCancellable?
    
    init() {
        
    }
    
    func captureKeyPress(mKeyPressed:Int,isBackPressed:Bool){
        
        let mCurrentSelectedNumber = mKeyPressed
        
        if isBackPressed {
            
            if mPressedKeys.count > 0 {
                mPressedKeys.removeLast()
            }

            return
        }
        
        if mPressedKeys.count < 6 {
            
            mPressedKeys.append(mCurrentSelectedNumber)
            
        }
        
        if mPressedKeys.count == 6 {
            comparePasscodes()
        }

    }
   
    func comparePasscodes(){
        
        aTempPasscode = mPressedKeys.map{String($0)}.joined(separator: "")
        
        if !aTempPasscode.isEmpty {
            if aTempPasscode == aSavedPasscode {
                mDismissAfterValidation = true
            }else{
                DeviceFeedbackHelper.longVibrate()
                mPasscodeValidationFailure = true
                mStateOfPins = mStateOfPins.map { _ in false }
                mPressedKeys.removeAll()
                aTempPasscode = ""
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.mPasscodeValidationFailure = false
                }
            }
        }
    }
    
    func updateLayout(isBackPressed:Bool){
        
        if mPressedKeys.count == 0 {
            mStateOfPins = mStateOfPins.map { _ in false }
            return
        }
        
       var mCurrentSelectedIndex = -1

       for index in 0 ..< mStateOfPins.count {
        if mStateOfPins[index] {
               mCurrentSelectedIndex = index
           }
       }

        if !isBackPressed {
            mCurrentSelectedIndex += 1
        }
        
        if mCurrentSelectedIndex < mStateOfPins.count && mPressedKeys.count > 0 {
            
            if isBackPressed {
                mStateOfPins[mCurrentSelectedIndex] = false
            }else{
                mStateOfPins[mCurrentSelectedIndex] = true
            }
           
        }
    }
    
}


struct PasscodeValidationScreen: View {
    
    @ObservedObject var passcodeViewModel = PasscodeValidationViewModel()
    
    @State var validateAndDismiss = false
    
    @State var isAuthenticationEnabled:Bool
    
    @Environment(\.presentationMode) var presentationMode:Binding<PresentationMode>
      
    let dragGesture = DragGesture()
    
    var body: some View {

        ZStack {

            PasscodeBackgroundView()
            
           
            VStack(alignment: .center, spacing: 10, content: {
                HStack{
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        VStack(alignment: .leading) {
                            ZStack{
                                Image("closebutton").resizable().frame(width: 50, height: 50)
                            }
                        }
                    }
                    .hidden(isAuthenticationEnabled)
                    .frame(width: 30, height: 30).padding(.top,30).multilineTextAlignment(.trailing)
                    .padding(.trailing,30)
                    
                }
                
                HStack(alignment: .center, spacing: nil, content: {
                    Spacer()
                    Text("Enter PIN".localized()).foregroundColor(.white).scaledFont(size: 20).padding(.top,20)
                    Spacer()
                })

                PasscodeScreenDescription(aDescription: "Please enter your PIN to proceed".localized(),size:Device.isLarge ? 15 : 10,padding:50)
                Spacer(minLength: 10)
                
                HStack(alignment: .center, spacing: 0, content: {
                    ForEach(0 ..< passcodeViewModel.mStateOfPins.count) { index in
                        PasscodePinImageView(isSelected: Binding.constant(passcodeViewModel.mStateOfPins[index]))
                    }
                }).padding(20)
                
                PasscodeScreenDescription(aDescription: "Remember your PIN. If you forget it, you won't be able to access your assets.".localized(),size:12,padding:50)
                
                PasscodeValidationNumberView(passcodeViewModel: Binding.constant(passcodeViewModel))
                Spacer(minLength: 10)
            }).padding(.top,10)
                .padding(.bottom,20)
            
        }
        .highPriorityGesture(dragGesture)
        .toast(isPresenting: Binding.constant(passcodeViewModel.mPasscodeValidationFailure)){
            AlertToast(displayMode: .hud, type: .regular, title:"Invalid passcode!".localized())

        }
        .onAppear(){
            
            self.passcodeViewModel.cancellable = self.passcodeViewModel
                            .$mDismissAfterValidation
                            .sink(receiveValue: { isDismiss in
                                guard isDismiss else { return }
                                if (isDismiss){
                                    self.presentationMode.wrappedValue.dismiss()
                                    if !isAuthenticationEnabled {
                                        NotificationCenter.default.post(name: NSNotification.Name("PasscodeValidationSuccessful"), object: nil)
                                    }
                                }
                            }
            )
            
            if(isAuthenticationEnabled){
                authenticate()
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onReceive(AuthenticationHelper.authenticationPublisher) { (output) in
                   switch output {
                   case .failed(_), .userFailed:
                       print("auth failed")
//                        UserSettings.shared.isBiometricDisabled = true
//                        NotificationCenter.default.post(name: NSNotification.Name("BioMetricStatusUpdated"), object: nil)
                   case .success:
                        UserSettings.shared.biometricInAppStatus = true
                        UserSettings.shared.isBiometricDisabled = false
                        self.passcodeViewModel.mDismissAfterValidation = true
                   case .userDeclined:
                        UserSettings.shared.biometricInAppStatus = false
                        UserSettings.shared.isBiometricDisabled = true
                        NotificationCenter.default.post(name: NSNotification.Name("BioMetricStatusUpdated"), object: nil)
                       break
                   }
            

       }
    }
    
    func authenticate() {
        if UserSettings.shared.biometricInAppStatus{
            AuthenticationHelper.authenticate(with: "Authenticate Biometric ID".localized())
        }
    }
}

//struct PasscodeValidationScreen_Previews: PreviewProvider {
//    static var previews: some View {
////        PasscodeValidationScreen()
//    }
//}
