//
//  HowItWorks.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//


import SwiftUI

enum ScreenSteps: Int {
    case step_one
    case step_two
    case step_three
    case move_next
    
    
    var id: Int {
        switch self {
        case .step_one:
            return 0
        case .step_two:
            return 1
        case .step_three:
            return 2
        case .move_next:
            return 3
        }
    }
    
    mutating func next(){
        self = ScreenSteps(rawValue: rawValue + 1) ?? ScreenSteps(rawValue: 0)!
    }
    
    mutating func back(){
        self = ScreenSteps(rawValue: rawValue - 1) ?? ScreenSteps(rawValue: 0)!
    }
}

final class HowItWorksViewModel: ObservableObject {
    
    @Published var mScreenTitle = "How it works - Step 1".localized()
    @Published var mDescriptionTitle = "Write down your key".localized()
    @Published var mDescriptionSubTitle = "Write down your key on paper and confirm it. Screenshots are not recommended for security reasons.".localized()
    @Published var mOpenGenerateWordsScreen = false
    @Published var destination: ScreenSteps = ScreenSteps.step_one
    
    func updateLayoutTextOrMoveToNextScreen(){
        
        destination.next()
        
        updateLayoutAccordingly()
        
    }
    
    func updateLayoutAccordingly(){
        
        switch (destination) {
        case .step_one:
            mScreenTitle = "How it works - Step 1".localized()
            mDescriptionTitle = "Write down your key".localized()
            mDescriptionSubTitle = "Write down your key on paper and confirm it. Screenshots are not recommended for security reasons.".localized()
            break
        case .step_two:
            mScreenTitle = "How it works - Step 2".localized()
            mDescriptionTitle = "Keep it secure".localized()
            mDescriptionSubTitle = "Store your key in a secure location. This is the only way to recover your wallet. Pirate Wallet does not keep a copy.".localized()
            break
        case .step_three:
            mScreenTitle = "How it works - Step 3".localized()
            mDescriptionTitle = "Store, send or receive".localized()
            mDescriptionSubTitle = "Store, send or receive knowing that your funds are protected by the best security and privacy in the business".localized()
            break
        case .move_next:
            mOpenGenerateWordsScreen = true
            break
        }
        
    }
    
}

struct HowItWorks: View {
    
    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @EnvironmentObject var viewModel: HowItWorksViewModel
    
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, content: {
                Text(self.viewModel.mDescriptionTitle).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil)
                    .scaledFont(size: Device.isLarge ? 26 : 20).padding(.top,80)
                Text(self.viewModel.mDescriptionSubTitle).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10)
                    .scaledFont(size: Device.isLarge ? 15 : 12)
                Spacer()
                Spacer()
                
                Button {
                    self.viewModel.updateLayoutTextOrMoveToNextScreen()
                } label: {
                    BlueButtonView(aTitle: "Continue".localized())
                }
                
                
                NavigationLink(
                    destination: GenerateWordsView(viewModel: GenerateWordsViewModel()).navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true),
                    isActive: $viewModel.mOpenGenerateWordsScreen
                ) {
                    EmptyView()
                }
                .isDetailLink(true)
            })
                .navigationBarBackButtonHidden(true)
                .navigationTitle(self.viewModel.mScreenTitle).navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:  Button(action: {
                    if self.viewModel.destination.id == 0 {
                        presentationMode.wrappedValue.dismiss()
                    }else{
                        self.viewModel.destination.back()
                        self.viewModel.updateLayoutAccordingly()
                    }
                    
                }) {
                    VStack(alignment: .leading) {
                        ZStack{
                            Image("backicon").resizable().frame(width: 50, height: 50)
                        }
                    }
                })
           
            
        }
    }
    
}

struct HowItWorks_Previews: PreviewProvider {
    static var previews: some View {
        HowItWorks()
    }
}
