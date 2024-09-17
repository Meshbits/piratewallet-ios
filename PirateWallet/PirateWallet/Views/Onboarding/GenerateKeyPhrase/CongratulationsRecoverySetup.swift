//
//  CongratulationsRecoverySetup.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import SwiftUI

struct CongratulationsRecoverySetup: View {
    @EnvironmentObject var viewModel: WordsVerificationViewModel
    @Environment(\.presentationMode) var presentationMode
    @State var openAuthenticatateFaceID = false
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack{
                Text("Congratulations! You completed your recovery phrase setup".localized()).padding(.trailing,30).padding(.leading,30).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil)
                    .scaledFont(size: Device.isLarge ? 22 : 16).padding(.top,40)
                Text("You’re all set to deposit, receive, and store crypto in your Pirate wallet".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).scaledFont(size: Device.isLarge ? 14 : 10)
                
                Spacer(minLength: 10)
                Image("flag")
                    .padding(.trailing,80).padding(.leading,80)
                
                Spacer(minLength: 10)
                
                BlueButtonView(aTitle: "Done".localized()).onTapGesture {
                    openAuthenticatateFaceID = true
                }
                
                
                NavigationLink(
                    destination: AuthenticateFaceID().environmentObject(viewModel).navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true).navigationBarHidden(true),
                    isActive: $openAuthenticatateFaceID
                ) {
                    EmptyView()
                }
            }
           
        }.navigationBarHidden(true)
        .navigationBarBackButtonHidden(true)
    }
}

struct CongratulationsRecoverySetup_Previews: PreviewProvider {
    static var previews: some View {
        CongratulationsRecoverySetup()
    }
}
