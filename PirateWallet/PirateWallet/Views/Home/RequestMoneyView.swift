//
//  RequestMoneyView.swift
//  PirateWallet
//
//  Created by Lokesh on 25/10/24.
//


import SwiftUI
import BottomSheet

struct RequestMoneyView<AccesoryContent: View>: View {
    let qrSize: CGFloat = Device.isLarge ? 100 : 70
    @State var isShareAddressShown = false
    @State var openFullScreenQRCode = false
    @State var sendArrrValue =  ""
    @State var memoTextContent =  ""

    @State var copyItemModel: PasteboardItemModel?
    var address: String
    @State var qrImage: Image = Image("zebra_profile")
    var badge: Image
    var chips: [String]
    @Environment(\.presentationMode) var presentationMode
    
    var accessoryContent: AccesoryContent
    
   
    var validForm: Bool {
        sufficientAmount && validMemo
    }
    
    var sufficientAmount: Bool {
        let amount = (Double(sendArrrValue) ??  0 )
        return amount > 0 ? true : false
    }
    
    var validMemo: Bool {
        memoTextContent.count >= 0 && memoTextContent.count <= PirateAppConfig.memoLengthLimit
    }
    
    init(address: String, chips: Int = 8, badge: Image, @ViewBuilder accessoryContent: (() -> (AccesoryContent))) {
        self.address = address
        self.chips = address.slice(into: chips)
        self.badge = badge
        self.accessoryContent = accessoryContent()
    }
    
    var body: some View {
        ZStack{
            ARRRBackground()
            VStack{
                
                HStack{
                    QRCodeContainer(qrImage: qrImage,
                                    badge: badge)
                        .frame(width: qrSize, height: qrSize, alignment: .center)
                        .layoutPriority(1)
                        .cornerRadius(6)
                        .modifier(QRCodeBackgroundPlaceholderModifier())
                        .onTapGesture {
                            openFullScreenQRCode = true
                        }
                    
                    Button(action: {
                        PasteboardAlertHelper.shared.copyToPasteBoard(value: self.address, notify: "feedback_addresscopied".localized())
                 
                    }) {
                        VStack {
                            if chips.count <= 2 {
                                
                                ForEach(0 ..< chips.count) { i in
                                    AddressFragment(number: i + 1, word: self.chips[i])
                                        .frame(height: 24)
                                }
                                self.accessoryContent
                            } else {
                                ForEach(stride(from: 0, through: chips.count - 1, by: 2).map({ i in i}), id: \.self) { i in
                                    HStack {
                                        AddressFragmentWithoutNumber(word: self.chips[i])
                                            .frame(height: 24)
                                        AddressFragmentWithoutNumber(word: self.chips[i+1])
                                            .frame(height: 24)
                                    }
                                }
                            }
                            
                        }
                        .frame(minHeight: Device.isLarge ? 96 : 70)
                        .padding(.leading, -10)
                        
                    }.alert(item: self.$copyItemModel) { (p) -> Alert in
                        PasteboardAlertHelper.alert(for: p)
                    }
                    .onReceive(PasteboardAlertHelper.shared.publisher) { (p) in
                        self.copyItemModel = p
                    }
                    
                    Spacer()
                }

                HStack{
                    Text("Memo".localized())
                        .scaledFont(size: Device.isLarge ? 20 : 12).foregroundColor(Color.textTitleColor)
                                    .frame(height: 22,alignment: .leading)
                                    .foregroundColor(Color.white)
                        .multilineTextAlignment(.leading)
                        .truncationMode(.middle).padding(.leading, 10)
                        .padding(10)
                    Spacer()
                }
                
                ARRRMemoTextField(memoText:$memoTextContent).frame(height:Device.isLarge ? 45 : 30)
                
//                Text(self.sendArrrValue)
//                    .foregroundColor(.gray)
//                    .scaledFont(size: 26)
//                    .frame(height:30)
//                    .padding(.leading,10)
//                    .padding(.trailing,10)
//                    .modifier(BackgroundPlaceholderModifier())
//
//                ARRRReceiveMoneyTextField(anAmount: self.$sendArrrValue)
                
                ARRRSendMoneyTextField(anAmount: self.$sendArrrValue)
                
                Spacer()
                
                GrayButtonView(aTitle: "Update QR Code".localized()).onTapGesture {
                    self.loadPirateChainURIAsQRCode()
                }
                
                BlueButtonView(aTitle: "Share".localized()).onTapGesture {
                    self.isShareAddressShown = true
                }.opacity(validForm ? 1.0 : 0.7 )
                .disabled(!validForm)
                
            }
            
        }.onTapGesture {
            UIApplication.shared.endEditing()
        }
        .keyboardAdaptive()
        .ARRRNavigationBar(leadingItem: {
            EmptyView()
         }, headerItem: {
             HStack{
                 Text("Request Money".localized())
                    .scaledFont(size: Device.isLarge ? 24 : 14)
                    .foregroundColor(Color.zSettingsSectionHeader)
                    .padding(.top,20)
             }
         }, trailingItem: {
             ARRRCloseButton(action: {
                 UIApplication.shared.endEditing()
                 presentationMode.wrappedValue.dismiss()
             }).frame(width: 15, height: 15).padding(.top,20)
         })
        .onAppear {
            self.loadPirateChainURIAsQRCode()
        }
        .navigationBarHidden(true)
        .sheet(isPresented: self.$isShareAddressShown) {
            ShareSheet(activityItems: [getPirateChainURI()])
        }
        .bottomSheet(isPresented: $openFullScreenQRCode,
                      height: 400,
                      topBarHeight: 0,
                      topBarCornerRadius: 20,
                      showTopIndicator: true) {
            FullScreenImageView(qrImage: $qrImage)
        }

    }
    
    func loadPirateChainURIAsQRCode(){
        let mPirateChainAddress = getPirateChainURI()
        if let img = QRCodeGenerator.generate(from: mPirateChainAddress) {
            self.qrImage =  Image(img, scale: 1, label: Text(String(format:NSLocalizedString("QR Code for %@", comment: ""),"\(mPirateChainAddress)") ))
        }else{
            self.qrImage = Image("zebra_profile")
        }
    }
    func getPirateChainURI() -> String {
        return PirateChainPaymentURI.init(build: {
            $0.address = self.address
            $0.amount = Double(self.sendArrrValue)
            $0.label = ""
            $0.message = self.memoTextContent
            $0.isDeepLink = true
        }).uri ?? self.address
    }
}

//struct RequestMoneyView_Previews: PreviewProvider {
//    static var previews: some View {
//        RequestMoneyView()
//    }
//}
