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
    
    @ViewBuilder func theUnscreen() -> some View {
        ZStack(alignment: .center) {
            ARRRBackground.darkSplashScreen
            ARRRLogo(fillStyle: Color.black)
                .frame(width: 167,
                       height: 167,
                       alignment: .center)
        }
        .navigationBarHidden(true)
        .onAppear() {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.removeSplash = true
//                do {
//                    let initialState = ZECCWalletEnvironment.getInitialState()
//                    switch initialState {
//                    case .unprepared, .initalized:
//                        try appEnvironment.initialize()
//                        appEnvironment.state = .initalized
//
//                    default:
//                        appEnvironment.state = initialState
//                    }
//
//                } catch {
//                    self.appEnvironment.state = .failure(error: error)
//                }
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
            IntroWelcome()
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
