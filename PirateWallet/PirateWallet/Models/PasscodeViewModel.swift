//
//  PasscodeViewModel.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import SwiftUI
import AlertToast
import LocalAuthentication

public class PasscodeViewModel: ObservableObject{
    
    @Published var mStateOfPins: [Bool] = [false,false,false,false,false,false] // To change the color of pins
    
    @Published var mPressedKeys: [Int] = [] // To keep the pressed content
    
    var aTempPasscode = ""
        
    var aTempConfirmPasscode = ""
    
    var aTempChangeConfirmPasscode = ""
    
    var aSavedPasscode = UserSettings.shared.aPasscode
    
    var changePinFlowInitiated = false
    
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
            if (!changePinFlowInitiated){
                comparePasscodes()
            }else{
                comparePasscodesForTemp()
            }
        }

    }
   
    func comparePasscodesForTemp(){
        if !aTempPasscode.isEmpty {
            aTempChangeConfirmPasscode = mPressedKeys.map{String($0)}.joined(separator: "")
            if aTempPasscode == aTempChangeConfirmPasscode {
                aTempConfirmPasscode = aTempChangeConfirmPasscode
                UserSettings.shared.aPasscode = aTempPasscode
                print("PASSCODE ARE SAME")
                NotificationCenter.default.post(name: NSNotification.Name("UpdateLayout"), object: nil)
            }else{
                print("PASSCODE IS NOT SAME")
                NotificationCenter.default.post(name: NSNotification.Name("UpdateErrorLayout"), object: nil)
            }
        }else{
            aTempPasscode = mPressedKeys.map{String($0)}.joined(separator: "")
            NotificationCenter.default.post(name: NSNotification.Name("UpdateLayout"), object: nil)
        }
        
    }
    
    func comparePasscodes(){
        
        if !aTempPasscode.isEmpty {
            aTempConfirmPasscode = mPressedKeys.map{String($0)}.joined(separator: "")
            if aTempPasscode == aTempConfirmPasscode {
                UserSettings.shared.aPasscode = aTempPasscode
                print("PASSCODE ARE SAME")
                NotificationCenter.default.post(name: NSNotification.Name("UpdateLayout"), object: nil)
            }else{
                print("PASSCODE IS NOT SAME")
                NotificationCenter.default.post(name: NSNotification.Name("UpdateErrorLayout"), object: nil)
            }
        }else{
            aTempPasscode = mPressedKeys.map{String($0)}.joined(separator: "")
            NotificationCenter.default.post(name: NSNotification.Name("UpdateLayout"), object: nil)
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

       if mCurrentSelectedIndex < mStateOfPins.count  && mPressedKeys.count > 0{
        
            if isBackPressed {
                mStateOfPins[mCurrentSelectedIndex] = false
            }else{
                mStateOfPins[mCurrentSelectedIndex] = true
            }
           
       }
    }
    
}
