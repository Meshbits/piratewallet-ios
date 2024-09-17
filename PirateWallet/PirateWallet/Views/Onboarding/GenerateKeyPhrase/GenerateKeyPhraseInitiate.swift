//
//  GenerateKeyPhraseInitiate.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import SwiftUI

struct GenerateKeyPhraseInitiate: View {
    
    @State var openHowItWorks = false
    
//    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    
    var body: some View {
//        NavigationView{
            ZStack{
                ARRRBackground().edgesIgnoringSafeArea(.all)
                VStack(alignment: .center, content: {
                    Text("Generate your private recovery phrase".localized()).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil)
                        .scaledFont(size: Device.isLarge ? 32 : 22).padding(.top,80)
                    Text("The key is required to recover your money if you upgrade or lose your phone".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10)
                        .scaledFont(size: Device.isLarge ? 17 : 12)
                    Spacer()
                    Spacer()
                    
                    NavigationLink(destination:
                                    HowItWorks().environmentObject(HowItWorksViewModel())
                            .navigationBarTitle("", displayMode: .inline)
                            .navigationBarBackButtonHidden(true)
                               
                        ,isActive: $openHowItWorks
                    ) {
                        EmptyView()
                    }
                    
                    
                    Button {
                        openHowItWorks = true
                    } label: {
                        BlueButtonView(aTitle: "Continue".localized())
                    }

                })
            }
//        }
        //.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct GenerateKeyPhraseInitiate_Previews: PreviewProvider {
    static var previews: some View {
        GenerateKeyPhraseInitiate()
    }
}
