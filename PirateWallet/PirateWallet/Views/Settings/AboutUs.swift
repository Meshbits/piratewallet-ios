//
//  AboutUs.swift
//  PirateWallet
//
//  Created by Lokesh on 20/11/24.
//


import SwiftUI

struct AboutUs: View {
    @Environment(\.presentationMode) var presentationMode
    var anAppVersion = "App Version: 2.0.0"
    var aBuildversion = "Build: 1"
    var aCommitsCount = "Commits Count: 59"
    var aGitHash = "Short Git hash: -"
    var aSourceCode = "Source: "
    var aSourceCodeURL = "https://github.com/Meshbits/piratewallet-ios/"
    var aDevelopedBy = "Developed by Meshbits Limited"
    var aVersionDetails = "Release: Beta"
    var mFontSize:CGFloat = Device.isLarge ? 15 : 12
    var mHeight:CGFloat = Device.isLarge ? 50 : 30
    
    var body: some View {
        
        ZStack {
                ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack {

                if #available(iOS 16.0, *) {
                    List {
                        
                        HStack{
                            Text(anAppVersion).multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .scaledFont(size: mFontSize)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        .listRowBackground(ARRRBackground())
                        .frame(minHeight: mHeight)
                        
                        HStack{
                            Text(aBuildversion).multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .scaledFont(size: mFontSize)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        .listRowBackground(ARRRBackground())
                        .frame(minHeight: mHeight)
                        
                        HStack{
                            Text(aCommitsCount).multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .scaledFont(size: mFontSize)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        .listRowBackground(ARRRBackground())
                        .frame(minHeight: mHeight)
                        
                        HStack{
                            Text(aGitHash).multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .scaledFont(size: mFontSize)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        .listRowBackground(ARRRBackground())
                        .frame(minHeight: mHeight)
                        
                        HStack{
                            Text(aVersionDetails).multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .scaledFont(size: mFontSize)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        .listRowBackground(ARRRBackground())
                        .frame(minHeight: mHeight)
                        
                        
                        HStack{
                            Link(aSourceCode+aSourceCodeURL, destination: URL(string: aSourceCodeURL)!)
                                .scaledFont(size: mFontSize)
                            Spacer()
                        }
                        .listRowBackground(ARRRBackground())
                        .frame(minHeight: mHeight)
                        
                    }
                    .scrollContentBackground(.hidden)
                    .listRowBackground(ARRRBackground())
                    .cornerRadius(0)
                    .modifier(BackgroundPlaceholderModifierHome())
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.zGray, lineWidth: 1.0)
                    )
                    .padding()
                } else {
                    // Fallback on earlier versions
                    List {
                        
                        HStack{
                            Text(anAppVersion).multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .scaledFont(size: mFontSize)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        .listRowBackground(ARRRBackground())
                        .frame(minHeight: mHeight)
                        
                        HStack{
                            Text(aBuildversion).multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .scaledFont(size: mFontSize)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        .listRowBackground(ARRRBackground())
                        .frame(minHeight: mHeight)
                        
                        HStack{
                            Text(aCommitsCount).multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .scaledFont(size: mFontSize)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        .listRowBackground(ARRRBackground())
                        .frame(minHeight: mHeight)
                        
                        HStack{
                            Text(aGitHash).multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .scaledFont(size: mFontSize)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        .listRowBackground(ARRRBackground())
                        .frame(minHeight: mHeight)
                        
                        HStack{
                            Text(aVersionDetails).multilineTextAlignment(.leading)
                                .lineLimit(nil)
                                .scaledFont(size: mFontSize)
                                .frame(alignment: .leading)
                            Spacer()
                        }
                        .listRowBackground(ARRRBackground())
                        .frame(minHeight: mHeight)
                        
                        
                        HStack{
                            Link(aSourceCode+aSourceCodeURL, destination: URL(string: aSourceCodeURL)!)
                                .scaledFont(size: mFontSize)
                            Spacer()
                        }
                        .listRowBackground(ARRRBackground())
                        .frame(minHeight: mHeight)
                        
                    }
                    .listRowBackground(ARRRBackground())
                    .cornerRadius(0)
                    .modifier(BackgroundPlaceholderModifierHome())
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.zGray, lineWidth: 1.0)
                    )
                    .padding()
                }
         
                HStack{
                    Spacer()
                    Text(aDevelopedBy).multilineTextAlignment(.leading)
                        .lineLimit(nil)
                        .scaledFont(size: mFontSize)
                        .frame(alignment: .leading)
                    Spacer()
                }.padding()
        }
        }  .navigationBarBackButtonHidden(true)
            .navigationTitle("About Pirate Wallet".localized()).navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:  Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                VStack(alignment: .leading) {
                    ZStack{
                        Image("backicon").resizable().frame(width: 50, height: 50)
                    }
                }
            })
    }
}

struct AboutUs_Previews: PreviewProvider {
    static var previews: some View {
        AboutUs()
    }
}
