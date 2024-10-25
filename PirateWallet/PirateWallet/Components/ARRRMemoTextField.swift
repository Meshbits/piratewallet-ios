//
//  ARRRMemoTextField.swift
//  PirateWallet
//
//  Created by Lokesh on 25/10/24.
//

import SwiftUI

struct ARRRMemoTextField: View {
   
    @Binding var memoText:String
    
    @State var isReplyTo = true
    
    var body: some View {
        ZStack{
           
            HStack{
                TextField("", text: $memoText,prompt: Text("Memo Text...".localized()).foregroundColor(.zLightGray))
                  .scaledFont(size: Device.isLarge ? 20 : 12)
                  .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.clear))
                  .foregroundColor(Color.white)
                  .modifier(QRCodeBackgroundPlaceholderModifier())
                
                Spacer()
                VStack{
                    Toggle(isOn: $isReplyTo) {
                        Text("")
                    }
                    .toggleStyle(ARRRToggleStyle(isHighlighted: $isReplyTo))
                    Text("Reply to".localized())
                        .scaledFont(size: Device.isLarge ? 14 : 8).foregroundColor(.gray)
                }.padding(.trailing, 10)
                Spacer()
            }
        }
    }
    
    
    var paragraphStyle: NSParagraphStyle {
        let p = NSMutableParagraphStyle()
        p.firstLineHeadIndent = 50
        return p
    }
    
}
//
//struct ARRRMemoTextField_Previews: PreviewProvider {
//    static var previews: some View {
//        ARRRMemoTextField()
//    }
//}


struct ARRRSendMoneyTextField: View {
    
     @Binding var anAmount:String
     var body: some View {
             
         ZStack{
             HStack{
                 TextField("", text: $anAmount,prompt: Text("Enter Amount".localized()).foregroundColor(.zLightGray))
                   .scaledFont(size: Device.isLarge ? 20 : 12)
                   .background(RoundedRectangle(cornerRadius: 10).foregroundColor(Color.clear))
                   .foregroundColor(Color.white)
                   .keyboardType(.decimalPad)
                   .foregroundColor(.gray)
                   .frame(height:Device.isLarge ? 30 : 20)
                   .multilineTextAlignment(.center)
                   .padding(.leading,10)
                   .padding(.trailing,10)
                   .modifier(BackgroundPlaceholderModifier())
                
             }
         }
         
     }
}

