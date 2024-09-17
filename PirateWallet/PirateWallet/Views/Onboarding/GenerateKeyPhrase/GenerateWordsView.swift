//
//  GenerateWordsView.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import SwiftUI
import Foundation

struct GenerateWordsView: View {
    
    @Environment(\.presentationMode) var presentationMode
//    @EnvironmentObject var appEnvironment: ZECCWalletEnvironment
    @ObservedObject var viewModel: GenerateWordsViewModel
    
    @State var isForward = true
    
    var body: some View {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, content: {
                Text("Your Recovery Phrase".localized()).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil)
                    .scaledFont(size: Device.isLarge ? 26 : 20)
                    .padding(.top,20)
                Text("Write down the following words in order".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).scaledFont(size: 15)
                Spacer()
                Text(self.viewModel.mWordTitle)/*.transition(.move(edge: isForward ? .trailing : .leading))*/.id("titleComponentID" + self.viewModel.mWordTitle).padding(.trailing,40).padding(.leading,40).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil)
//                    .transition(
//                        .asymmetric(
//                            insertion: .move(edge: isForward ? .trailing : .leading),
//                            removal: .move(edge: isForward ? .leading : .trailing)
//                        )
//                    )
//                    .animation(.default)
//                    .id(UUID())
                    .padding(.top,80)
                Text("\(self.viewModel.mWordIndex) of 24").padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10)
                    .scaledFont(size: 17)
                Spacer()
                
//                Image(self.viewModel.mWordIndex%2==0 ? "leftbgwords" : "rightbgwords")
//                    .transition(
//                    .asymmetric(
//                        insertion: .move(edge: isForward ? .trailing : .leading),
//                        removal: .move(edge: isForward ? .leading : .trailing)
//                    )
//                )
//                .animation(.default)
//                .id(UUID())
                
                Text("For security purposes, do not screenshot or email these words.".localized()).padding(.trailing,40).padding(.leading,40).foregroundColor(.gray).multilineTextAlignment(.leading).foregroundColor(.gray).padding(.top,10)
                    .scaledFont(size: 12)
                Button {
                    self.isForward = true
//                    withAnimation(.easeInOut(duration: 0.2), {
                        self.viewModel.updateLayoutTextOrMoveToNextScreen()
//                   })
                } label: {
                    BlueButtonView(aTitle: "Next".localized())
                }
              
                
                NavigationLink(
                    destination: WordsVerificationScreen(viewModel:WordsVerificationViewModel(mPhrase:self.viewModel.randomKeyPhrase!)).navigationBarTitle("", displayMode: .inline)
                        .navigationBarBackButtonHidden(true),
                    isActive: $viewModel.mWordsVerificationScreen
                ) {
                    EmptyView()
                }
                
            })  .navigationBarBackButtonHidden(true)
                .navigationTitle("").navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(leading:  Button(action: {
                    if self.viewModel.mWordIndex == 1 {
                        presentationMode.wrappedValue.dismiss()
                    }else{
                        isForward = false
//                        withAnimation(.easeIn(duration: 0.2), {
                            self.viewModel.backPressedToPopBack()
//                       })
                    }
                    
                }) {
                    VStack(alignment: .leading) {
                        ZStack{
                            Image("backicon").resizable().frame(width: 50, height: 50)
                        }
                    }
                })
                
            
        }
        .highPriorityGesture(DragGesture(minimumDistance: 3.0, coordinateSpace: .local).onEnded { value in
            
//            if value.translation.width < 0 && value.translation.height > -80 && value.translation.height < 80 {
////                withAnimation(.easeInOut(duration: 0.2), {
//                    self.isForward = true
//                    self.viewModel.updateLayoutTextOrMoveToNextScreen()
////               })
//            }
//            else if value.translation.width > 0 && value.translation.height > -80 && value.translation.height < 80 {
////                withAnimation(.easeIn(duration: 0.2), {
//                    self.isForward = false
//                    self.viewModel.backPressedToPopBack()
////               })
//            }
//            else {
//                print("other gesture we don't worry about")
//            }
        })
    }
    
}

struct GenerateWordsView_Previews: PreviewProvider {
    static var previews: some View {
        GenerateWordsView(viewModel: GenerateWordsViewModel())
    }
}

