//
//  AdjustBackgroundVolume.swift
//  PirateWallet
//
//  Created by Lokesh on 21/11/24.
//


import SwiftUI

struct AdjustBackgroundVolume: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State var sliderValue: Float = UserSettings.shared.mBackgroundSoundVolume ?? 0.05
    
    @State var isChecked = UserSettings.shared.isBackgroundSoundEnabled
    
    var body: some View {
        ZStack{
            
            ARRRBackground().edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .center, spacing: 5) {
                                  
                Slider(value: $sliderValue, in: 0.05...1, step: 0.05)
                    .accentColor(Color.arrrBarAccentColor)
                    .frame(height: 40)
                    .padding(.leading,50)
                    .padding(.trailing,50)
                      .padding(.horizontal)
                Text("\(sliderValue, specifier: "%.2f")")
                    .scaledFont(size: Device.isLarge ?  16 : 12)
                    .foregroundColor(Color.textTitleColor)
                
                VolumeCheckBoxView(isChecked: $isChecked, title: "Enable Sound in foreground".localized())
                    .padding(.top,80)
      
            }
            .padding(.top,40)
            
            
        }
        .navigationBarBackButtonHidden(true)
        .navigationTitle("Adjust Background Volume".localized()).navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(leading:  Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            VStack(alignment: .leading) {
                ZStack{
                    Image("backicon").resizable().frame(width: 50, height: 50)
                }
            }
        })
        .onDisappear {
            UserSettings.shared.mBackgroundSoundVolume = sliderValue
        }
    }
}
