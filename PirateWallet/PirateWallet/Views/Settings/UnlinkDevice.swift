//
//  UnlinkDevice.swift
//  PirateWallet
//
//  Created by Lokesh on 20/11/24.
//


import SwiftUI

struct UnlinkDevice: View {
    @Environment(\.presentationMode) var presentationMode
    @State var goToRecoveryPhrase = false
    var body: some View {
                ZStack{
                    ARRRBackground().edgesIgnoringSafeArea(.all)
                        VStack(alignment: .center, content: {
                            Spacer(minLength: 10)
                            Text("Delete your wallet from this device".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil)
                                .scaledFont(size: Device.isLarge ? 26 : 22).padding(.top,40)
                            Text("Start a new wallet by removing your device from the currently installed wallet".localized()).padding(.trailing,80).padding(.leading,80).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).scaledFont(size: Device.isLarge ? 15 : 12)
                            Spacer(minLength: 10)
                            Image("bombIcon")
                                .padding(.trailing,80).padding(.leading,80)
                            
                            Spacer(minLength: 10)
                            Button {
                                goToRecoveryPhrase = true
                               
                            } label: {
                                BlueButtonView(aTitle: "Continue".localized())
                                
                            }
                            
                            NavigationLink(
                                destination: RecoveryBasedUnlink().environmentObject(RecoveryViewModel()),
                                isActive: $goToRecoveryPhrase
                            ) {
                               EmptyView()
                            }
                            
                            Spacer(minLength: 10)
                        })
                    
                    
                    }.edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true)
                .navigationTitle("").navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:  Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack(alignment: .leading) {
                        ZStack{
                            Image("backicon").resizable().frame(width: 50, height: 50)
                        }
                    }
                })
                .onAppear(){
                    NotificationCenter.default.addObserver(forName: NSNotification.Name("NukedUser"), object: nil, queue: .main) { (_) in
                        UserSettings.shared.removeAllSettings()
                        SeedManager.default.nukeWallet()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                              NotificationCenter.default.post(name: NSNotification.Name("MoveToFirstViewLayout"), object: nil)
                        }
                    }
                }
    }
}

struct UnlinkDevice_Previews: PreviewProvider {
    static var previews: some View {
        UnlinkDevice()
    }
}
