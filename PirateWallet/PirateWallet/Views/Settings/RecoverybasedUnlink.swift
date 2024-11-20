//
//  RecoverybasedUnlink.swift
//  PirateWallet
//
//  Created by Lokesh on 20/11/24.
//


import SwiftUI
import AlertToast

final class RecoveryViewModel: ObservableObject {
    
    @Published var firstWord = ""
    @Published var secondWord = ""
    @Published var thirdWord = ""
    @Published var firstWordIndex:Int = 0
    @Published var secondWordIndex:Int = 0
    @Published var thirdWordIndex:Int = 0
    var mSeedPhrase: String {
        do {
            return try SeedManager.default.exportPhrase()
        } catch {
            return ""
        }
    }
    @Published var mCompletePhrase:[String]?
    @Published var mWordsVerificationCompleted = false
  
    init() {
        
        mCompletePhrase = mSeedPhrase.components(separatedBy: " ")
        assignElementsOnUI()
//        print(mCompletePhrase)
    }
    
    func assignElementsOnUI(){
        
        let indexes = getRandomWordsIndex()
        
        if (mCompletePhrase!.count > 0){
            firstWordIndex = indexes[0]
            secondWordIndex = indexes[1]
            thirdWordIndex = indexes[2]
        }
        
    }
    
    
    func validateAndMoveToNextScreen(){
        
        if (!firstWord.isEmpty && firstWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == mCompletePhrase![firstWordIndex].lowercased().trimmingCharacters(in: .whitespacesAndNewlines)){
            
            if (!secondWord.isEmpty && secondWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == mCompletePhrase![secondWordIndex].lowercased().trimmingCharacters(in: .whitespacesAndNewlines)){
                
                if (!thirdWord.isEmpty && thirdWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == mCompletePhrase![thirdWordIndex].lowercased().trimmingCharacters(in: .whitespacesAndNewlines)){
                    
                    mWordsVerificationCompleted = true
                    
                    print("MATCHED AND NOW UNLINK IT HERE")
                    
                    
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateErrorLayoutInvalidDetailsRecovery"), object: nil)
                    print("NOT MATCHED AND NOTIFY USER")
                }
                
            }else{
                NotificationCenter.default.post(name: NSNotification.Name("UpdateErrorLayoutInvalidDetailsRecovery"), object: nil)
                print("NOT MATCHED AND NOTIFY USER")
            }
            
        }else{
            NotificationCenter.default.post(name: NSNotification.Name("UpdateErrorLayoutInvalidDetailsRecovery"), object: nil)
            print("NOT MATCHED AND NOTIFY USER")
        }
        
        
    }
    
    func getRandomWordsIndex()->[Int]{
          
          var allIndexes = Array(0...23)
        
          var uniqueNumbers = [Int]()
          
          while allIndexes.count > 0 {
              
              let number = Int(arc4random_uniform(UInt32(allIndexes.count)))
              
                uniqueNumbers.append(allIndexes[number])
              
                allIndexes.swapAt(number, allIndexes.count-1)
              
                allIndexes.removeLast()
            
                if uniqueNumbers.count == 3 {
                    break
                }
          }
          
          return uniqueNumbers
      }
    
}

struct RecoveryBasedUnlink: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var viewModel: RecoveryViewModel
    @State var isConfirmButtonEnabled = false
    @State private var showErrorToast = false
    var body: some View {
//        NavigationView {
        ZStack{
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack{
                Text("Enter Recovery Phrase".localized()).padding(.trailing,80).padding(.leading,80).foregroundColor(.white).multilineTextAlignment(.center).lineLimit(nil).scaledFont(size: Device.isLarge ?  28 : 20).padding(.top,40)
                Text("Please enter your recovery phrase to delete the wallet from your device".localized()).padding(.trailing,60).padding(.leading,60).foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).padding(.top,10).scaledFont(size: Device.isLarge ? 17 : 12)
                
                HStack(spacing: nil, content: {
                   
                    VStack{
                        Text("Word #\(self.viewModel.firstWordIndex + 1)").foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).font(.barlowRegular(size: Device.isLarge ? 16 : 12))
                        TextField("".localized(), text: self.$viewModel.firstWord, onEditingChanged: { (changed) in
                        }) {
     //                       self.didEndEditingAddressTextField()
                        }.scaledFont(size: Device.isLarge ?  14 : 12)
                        .multilineTextAlignment(.center)
                        .textCase(.lowercase)
                        .autocapitalization(.none)
                        .modifier(WordBackgroundPlaceholderModifier())
                    }
                    
                    VStack{
                        Text("Word #\(self.viewModel.secondWordIndex + 1)").foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).font(.barlowRegular(size: Device.isLarge ? 16 : 12))
                        TextField("".localized(), text: self.$viewModel.secondWord, onEditingChanged: { (changed) in
                        }){
      //                      self.didEndEditingPortTextField()
                        }.scaledFont(size: Device.isLarge ?  14 : 12)
                        .multilineTextAlignment(.center)
                        .textCase(.lowercase)
                        .autocapitalization(.none)
                        .modifier(WordBackgroundPlaceholderModifier())
                    }
                     
                    VStack{
                        Text("Word #\(self.viewModel.thirdWordIndex + 1)").foregroundColor(.gray).multilineTextAlignment(.center).foregroundColor(.gray).font(.barlowRegular(size: Device.isLarge ? 16 : 12))
                        TextField("".localized(), text: self.$viewModel.thirdWord, onEditingChanged: { (changed) in
                        }) {
      //                      self.didEndEditingPortTextField()
                        }.scaledFont(size: Device.isLarge ?  14 : 12)
                        .multilineTextAlignment(.center)
                        .textCase(.lowercase)
                        .autocapitalization(.none)
                        .modifier(WordBackgroundPlaceholderModifier())
                    }
                                           
                }).modifier(ForegroundPlaceholderModifier())
                .padding(10)
                Spacer(minLength: 10)
                Spacer(minLength: 10)
                Spacer(minLength: 10)
                
                BlueButtonView(aTitle: "Delete".localized()).onTapGesture {
                    if self.viewModel.firstWord.isEmpty || self.viewModel.secondWord.isEmpty || self.viewModel.thirdWord.isEmpty {
                        self.isConfirmButtonEnabled = false
                    }else{
                        self.isConfirmButtonEnabled = true
                    }
                    
                    self.viewModel.validateAndMoveToNextScreen()
                    
                }.padding(.bottom,10)
                .alert(isPresented: $viewModel.mWordsVerificationCompleted) {
                    Alert(title: Text("nuke_alerttitle".localized()),
                          message: Text("nuke_alertmessage".localized()),
                          primaryButton: .default(
                            Text("nuke_alertcancel".localized())
                            ,action: { }
                        ),
                          secondaryButton: .destructive(
                            Text("nuke_alertconfirm".localized()),
                            action: {
                                presentationMode.wrappedValue.dismiss()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    NotificationCenter.default.post(name: NSNotification.Name("NukedUser"), object: nil)
                                }
                                
                          }
                        )
                    )
                }
                
                
//                NavigationLink(
//                    destination: CongratulationsRecoverySetup().environmentObject(viewModel).navigationBarTitle("", displayMode: .inline).navigationBarHidden(true)
//                        .navigationBarBackButtonHidden(true),
//                    isActive: $viewModel.mWordsVerificationCompleted
//                ) {
//                    EmptyView()
//                }
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .topLeading)
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
           
        }
        .onAppear(){
            NotificationCenter.default.addObserver(forName: NSNotification.Name("UpdateErrorLayoutInvalidDetailsRecovery"), object: nil, queue: .main) { (_) in
                showErrorToast = true
                aSmallErrorVibration()
            }
        }.toast(isPresenting: $showErrorToast){
            
            AlertToast(displayMode: .hud, type: .regular, title:"Invalid passphrase!".localized())

        } .onTapGesture {
            UIApplication.shared.endEditing()
//        }
        } .navigationBarBackButtonHidden(true)
            .navigationTitle("".localized())
                .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:   Button {
                presentationMode.wrappedValue.dismiss()
            } label: {
                Image("backicon").resizable().frame(width: 50, height: 50)
            })
    }
    
    func aSmallErrorVibration(){
        let vibrationGenerator = UINotificationFeedbackGenerator()
        vibrationGenerator.notificationOccurred(.error)
    }
    
}

