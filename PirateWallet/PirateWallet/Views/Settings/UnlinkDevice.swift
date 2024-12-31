//
//  UnlinkDevice.swift
//  PirateWallet
//
//  Created by Lokesh on 20/11/24.
//


import SwiftUI
import AlertToast
import Combine
import PirateLightClientKit

final class UnlinkDeviceViewModel: ObservableObject {
    
    @Published var syncStatus: SyncStatus = .upToDate
    private var cancellable = [AnyCancellable]()
    
    init()
    {
        Task { @MainActor in
            if let aSynchronizer = PirateAppSynchronizer.shared.synchronizer  {
                aSynchronizer.stateStream
                    .throttle(for: .seconds(0.2), scheduler: DispatchQueue.main, latest: true)
                    .sink(receiveValue: { [weak self] state in self?.synchronizerStateUpdatedUnlinkDevice(state) })
                    .store(in: &cancellable)
            }
        }
    }
    
    private func synchronizerStateUpdatedUnlinkDevice(_ state: SynchronizerState) {
        printLog("Logging inside UnlinkDeviceModel.synchronizerStateUpdatedUnlinkDevice")
        printLog(state.syncStatus)
        syncStatus = state.syncStatus
    }
    
    
}

struct UnlinkDevice: View {
    @Environment(\.presentationMode) var presentationMode
    @State var goToRecoveryPhrase = false
    @State var cantSendError = false
    @StateObject var unlinkDeviceViewModel = UnlinkDeviceViewModel()
    
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
                                
                                if unlinkDeviceViewModel.syncStatus == .upToDate {
                                    goToRecoveryPhrase = true
                                }else{
                                    cantSendError = true
                                }
                                
                               
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
                        PirateAppConfig.resetConfigDefaults()
                        UserSettings.shared.removeAllSettings()
                        SeedManager.default.nukeWallet()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                              NotificationCenter.default.post(name: NSNotification.Name("MoveToFirstViewLayout"), object: nil)
                        }
                    }
                }
                .toast(isPresenting: $cantSendError){

                    AlertToast(displayMode: .hud, type: .regular, title:"Please wait, You cannot delete your wallet while ARRR Wallet Syncing is in progress.".localized())

                }
    }
}

struct UnlinkDevice_Previews: PreviewProvider {
    static var previews: some View {
        UnlinkDevice()
    }
}
