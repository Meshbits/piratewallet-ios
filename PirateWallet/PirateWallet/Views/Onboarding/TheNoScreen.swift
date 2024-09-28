//
//  TheNoScreen.swift
//  PirateWallet
//
//  Created by Lokesh on 13/09/24.
//

import SwiftUI

struct TheNoScreen: View {
//    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @State var removeSplash: Bool = false
    @State var openHomeScreen = false
    
    @ViewBuilder func theUnscreen() -> some View {
        ZStack(alignment: .center) {
            ARRRBackground.darkSplashScreen
            ARRRLogo(fillStyle: Color.black)
                .frame(width: 167,
                       height: 167,
                       alignment: .center)
            NavigationLink(destination:
                            HomeTabView(openPasscodeScreen: false)
                            .navigationBarHidden(true)
                            .navigationBarBackButtonHidden(true)
                            .navigationBarTitle("", displayMode: .inline)
            , isActive: $openHomeScreen) {
                EmptyView()
            }
        }
        .navigationBarHidden(true)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                
                if UserSettings.shared.currentSyncStatus == LocalSyncStatus.inProgress.rawValue {
                    self.openHomeScreen = true
                }else{
                    self.removeSplash = true
                }
            }
        }
    }
    
//    @ViewBuilder func viewForState(_ state: WalletState) -> some View {
//        switch state {
//        case .unprepared:
//            theUnscreen()
//        case .initalized,
//             .syncing,
//             .synced:
//
//
////            Home().environmentObject(HomeViewModel())
//            
////            NavigationView {
//                if let aPasscode = UserSettings.shared.aPasscode, !aPasscode.isEmpty {
//                    LazyView(
//                        HomeTabView(openPasscodeScreen: true))
//                }else{
//                    PasscodeScreen(passcodeViewModel: PasscodeViewModel(), mScreenState: .newPasscode)
//                }
////            }.navigationViewStyle(StackNavigationViewStyle())
//            
//
////            Home(viewModel: ModelFlyWeight.shared.modelBy(defaultValue: HomeViewModel()))
////                .environmentObject(appEnvironment)
//                
//
//        case .uninitialized:
//            CreateNewWallet().environmentObject(appEnvironment)
//        
//        case .failure(let error):
//            // Handled the case when it throws an error/failure in setup - so it's best to reset and clear it.
//            theUnscreen().onAppear(){
//                ZECCWalletEnvironment.shared.nuke(abortApplication: true)
//            }
//            // Keep error for later use and removed backup flow
////            OhMyScreen().environmentObject(
////                OhMyScreenViewModel(failure: mapToUserFacingError(ZECCWalletEnvironment.mapError(error: error)))
////            )
//        }
//    }
    var body: some View {
//        viewForState(appEnvironment.state)
        
        if removeSplash {
            CreateNewWallet()
                .transition(.opacity)
        }else{
            theUnscreen()
                .transition(.opacity)
        }
        
        
    }
}

//struct TheNoScreen_Previews: PreviewProvider {
//    static var previews: some View {
//        TheNoScreen()
//    }
//}
