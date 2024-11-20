//
//  PasscodeUtilities.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import SwiftUI
import AlertToast
import LocalAuthentication

struct PasscodeScreenTopImageView : View {
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            Spacer()
            Image("passcodeIcon").padding(.horizontal)
            Spacer()
        })
    }
}

struct PasscodeBackgroundView : View {
    var body: some View{
        Rectangle().fill(LinearGradient(gradient: Gradient(colors: [Color.zDarkGradient1, Color.zDarkGradient2]), startPoint: .top, endPoint: .bottom)).edgesIgnoringSafeArea(.all)
    }
}

struct PasscodeScreenSubTitle : View {
    @State var aSubTitle: String
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            Spacer()
            Text(aSubTitle).foregroundStyle(.white)
            .scaledFont(size: Device.isLarge ? 22 : 14)
            .padding(.trailing,5)
            Spacer()
        })
    }
}


struct PasscodeScreenTitle : View {
    @State var aTitle: String
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            Spacer()
            Text(aTitle).scaledFont(size: 18).foregroundStyle(.gray).padding(.top,20)
            Spacer()
        })
    }
}


struct PasscodeScreenDescription : View {
    @State var aDescription: String
    @State var size: CGFloat
    @State var padding:CGFloat
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            Spacer()
            Text(aDescription).lineLimit(nil).foregroundStyle(Color.zARRRSubtitleColor)
                .scaledFont(size: size).padding(.leading,padding).padding(.trailing,padding).multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
            Spacer()
        })
    }
}

struct PasscodePinImageView: View {
    @Binding var isSelected:Bool
    
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            Image(isSelected ? "radioiconselected" : "radioiconunselected")
        }).frame(width: 40, height: 40, alignment: .center)
    }
}


struct PasscodeNumberView : View {
    @Binding var passcodeViewModel: PasscodeViewModel
    var body: some View {
        VStack (spacing: 5, content:{
            PasscodeNumpadRow(startIndex: Binding.constant(1), endIndex: Binding.constant(4),passcodeViewModel: Binding.constant(passcodeViewModel))
            PasscodeNumpadRow(startIndex: Binding.constant(4), endIndex: Binding.constant(7),passcodeViewModel: Binding.constant(passcodeViewModel))
            PasscodeNumpadRow(startIndex: Binding.constant(7), endIndex: Binding.constant(10),passcodeViewModel: Binding.constant(passcodeViewModel))
            HStack(alignment: .center, spacing: 5, content: {
                
                PasscodeNumber(passcodeValue: Binding.constant(""),passcodeViewModel: $passcodeViewModel).hidden()
                PasscodeNumber(passcodeValue: Binding.constant("0"),passcodeViewModel: $passcodeViewModel)
                PasscodeNumber(passcodeValue: Binding.constant("delete"),passcodeViewModel: $passcodeViewModel)
            })
        })
            .frame(width: Device.isLarge ? 300 : 200, alignment: .center)
    }
}



struct PasscodeValidationNumberView : View {
    @Binding var passcodeViewModel: PasscodeValidationViewModel
    var body: some View {
        VStack {
            PasscodeValidationNumpadRow(startIndex: Binding.constant(1), endIndex: Binding.constant(4),passcodeViewModel: Binding.constant(passcodeViewModel))
            PasscodeValidationNumpadRow(startIndex: Binding.constant(4), endIndex: Binding.constant(7),passcodeViewModel: Binding.constant(passcodeViewModel))
            PasscodeValidationNumpadRow(startIndex: Binding.constant(7), endIndex: Binding.constant(10),passcodeViewModel: Binding.constant(passcodeViewModel))
            HStack(alignment: .center, spacing: nil, content: {
                
                PasscodeValidationNumber(passcodeValue: Binding.constant(""),passcodeViewModel: $passcodeViewModel).hidden()
                PasscodeValidationNumber(passcodeValue: Binding.constant("0"),passcodeViewModel: $passcodeViewModel)
                PasscodeValidationNumber(passcodeValue: Binding.constant("delete"),passcodeViewModel: $passcodeViewModel)
            })
        } .frame(width: 250, alignment: .center)
    }
}


struct PasscodeValidationNumber: View {
    
    @Binding var passcodeValue: String
    
    @Binding var passcodeViewModel: PasscodeValidationViewModel
    
    func aSmallVibration(){
        let vibrationGenerator = UINotificationFeedbackGenerator()
        vibrationGenerator.notificationOccurred(.warning)
    }
    
    var body: some View {
        
            Button(action: {
                
                if passcodeValue == "delete" {
                    passcodeViewModel.captureKeyPress(mKeyPressed: -1, isBackPressed: true)
                }else{
                    passcodeViewModel.captureKeyPress(mKeyPressed: Int(passcodeValue)!, isBackPressed: false)
                }
                
                passcodeViewModel.updateLayout(isBackPressed: passcodeValue == "delete" ? true : false)
                
                aSmallVibration()

            }, label: {
                ZStack {
                    Image("passcodenumericbg").resizable().frame(width: Device.isLarge ? 100 : 60, height: Device.isLarge ? 100 : 60, alignment: .center)

                    if passcodeValue == "delete" {
                        Text("").foregroundColor(.white)
                        Image(systemName: "delete.left").foregroundColor(.gray).scaledFont(size: Device.isLarge ? 15 : 12)
                    }else {
                        Text(passcodeValue).foregroundColor(.gray).bold().multilineTextAlignment(.center).scaledFont(size: Device.isLarge ? 22 : 14)
                            .padding(.bottom,2)
                            .padding(.trailing,2)
                        
                    }
                }.padding(2)
            })
    }
    
}



struct PasscodeValidationNumpadRow: View {
    
    @Binding var startIndex : Int
    @Binding var endIndex : Int
    @Binding var passcodeViewModel: PasscodeValidationViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: nil, content: {
            ForEach(startIndex ..< endIndex) { index in
                PasscodeValidationNumber(passcodeValue: Binding.constant(String(index)),passcodeViewModel: $passcodeViewModel)
            }
        })
    }
}


struct PasscodeNumpadRow: View {
    
    @Binding var startIndex : Int
    @Binding var endIndex : Int
    @Binding var passcodeViewModel: PasscodeViewModel
    
    var body: some View {
        HStack(alignment: .center, spacing: 5, content: {
            ForEach(startIndex ..< endIndex) { index in
                PasscodeNumber(passcodeValue: Binding.constant(String(index)),passcodeViewModel: $passcodeViewModel)
            }
        })
    }
}

struct PasscodeNumber: View {
    
    @Binding var passcodeValue: String
    
    @Binding var passcodeViewModel: PasscodeViewModel
    
    func aSmallVibration(){
        let vibrationGenerator = UINotificationFeedbackGenerator()
        vibrationGenerator.notificationOccurred(.warning)
    }
    
    var body: some View {
        
            Button(action: {
               
                if passcodeValue == "delete" {
                    passcodeViewModel.captureKeyPress(mKeyPressed: -1, isBackPressed: true)
                }else{
                    passcodeViewModel.captureKeyPress(mKeyPressed: Int(passcodeValue)!, isBackPressed: false)
                }
                
                passcodeViewModel.updateLayout(isBackPressed: passcodeValue == "delete" ? true : false)
                
                aSmallVibration()

            }, label: {
                ZStack {
                    Image("passcodenumericbg").resizable().frame(width: Device.isLarge ? 100 : 60, height: Device.isLarge ? 100 : 60, alignment: .center)
                        .padding(.top,3)
                        .padding(.leading,3)
                    if passcodeValue == "delete" {
                        Text("").foregroundColor(.white)
                        Image(systemName: "delete.left").foregroundColor(.gray).scaledFont(size: Device.isLarge ? 15 : 12)
                    }else {
                        Text(passcodeValue).foregroundColor(.gray).bold().multilineTextAlignment(.center).scaledFont(size: Device.isLarge ? 22 : 14)
                    }
                }
            })
    }
    
}
