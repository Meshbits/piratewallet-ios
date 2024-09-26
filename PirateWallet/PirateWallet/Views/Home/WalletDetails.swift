//
//  WalletDetails.swift
//  PirateWallet
//
//  Created by Lokesh on 23/09/24.
//


import SwiftUI
import Combine

//struct WalletDetails: View {
//    @StateObject var viewModel: WalletDetailsViewModel
//    @Environment(\.presentationMode) var presentationMode
//    @Binding var isActive: Bool
//    @State var selectedModel: DetailModel? = nil
//    var zAddress: String {
//        viewModel.zAddress
//    }
//    
//    var status: BalanceStatus {
//        viewModel.balanceStatus
//    }
//    
//    func converDateToString(headerDate:Date) -> String{
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .short
//        dateFormatter.doesRelativeDateFormatting = true
//        return dateFormatter.string(from: headerDate)
//    }
//    
//    var body: some View {
//        
//        ZStack {
//            ARRRBackground()
//            VStack(alignment: .center, spacing: 20) {
//                
//                VStack(alignment: .center, spacing: 10) {
//                    Text("Wallet History".localized()).scaledFont(size: Device.isLarge ? 20 : 12).multilineTextAlignment(.center).foregroundColor(.white)
//                }.padding(.top,Device.isLarge ? 50 : 30)
//                
//                ARRRNavigationBar(
//                    leadingItem: {
//
//                    },
//                   headerItem: {
////                    if appEnvironment.synchronizer.synchronizer.getShieldedBalance() > 0 {
//                        BalanceDetailView(
//                            availableZec: (PirateAppSynchronizer.shared.synchronizer?.getShieldedBalance().decimalValue.doubleValue)!,
//                                status: status)
//                                
////                    }
////                    else {
////                        ActionableMessage(message: "balance_nofunds".localized())
////                    }
//                   },
//                   trailingItem: { EmptyView() }
//                )
//                .padding(.horizontal, 10)
//                
//
//                if #available(iOS 16.0, *) {
//                    List {
//                        
//                        ForEach(self.viewModel.headers, id: \.self) { header in
//                            
//                            Section(header: Text(converDateToString(headerDate: header)).font(.barlowRegular(size: 20)).foregroundColor(Color.zSettingsSectionHeader).background(Color.clear).cornerRadius(20)) {
//                                ForEach(self.viewModel.groupedByDate[header]!) { row in
//                                    Button(action: {
//                                        self.selectedModel = row
//                                    }) {
//                                        DetailCard(model: row, backgroundColor: .zDarkGray2,isFromWalletDetails:true)
//                                    }
//                                    .buttonStyle(PlainButtonStyle())
//                                    .frame(height: 60)
//                                    .cornerRadius(0)
//                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                    
//                                }
//                            }
//                        }
//                        
//                    }
//                    .modifier(BackgroundPlaceholderModifierRescanOptions())
//                        .scrollContentBackground(.hidden)
//                        .padding()
//                } else {
//                    // Fallback on earlier versions
//                    List {
//                        
//                        ForEach(self.viewModel.headers, id: \.self) { header in
//                            
//                            Section(header: Text(converDateToString(headerDate: header)).font(.barlowRegular(size: 20)).foregroundColor(Color.zSettingsSectionHeader).background(Color.clear).cornerRadius(20)) {
//                                ForEach(self.viewModel.groupedByDate[header]!) { row in
//                                    Button(action: {
//                                        self.selectedModel = row
//                                    }) {
//                                        DetailCard(model: row, backgroundColor: .zDarkGray2,isFromWalletDetails:true)
//                                    }
//                                    .buttonStyle(PlainButtonStyle())
//                                    .frame(height: 60)
//                                    .cornerRadius(0)
//                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
//                                    
//                                }
//                            }
//                        }
//                        
//                    }
//                    .modifier(BackgroundPlaceholderModifierRescanOptions())
//                }
//                
//            }
//        }
//        .onAppear() {
//            
//            UITableView.appearance().separatorStyle = .none
//            UITableView.appearance().backgroundColor = UIColor.clear
//
//        }
//        .alert(isPresented: self.$viewModel.showError) {
//            Alert(title: Text("Error".localized()),
//                  message: Text("an error ocurred".localized()),
//                  dismissButton: .default(Text("button_close".localized())))
//        }
//        .onDisappear() {
//            UITableView.appearance().separatorStyle = .singleLine
//        }
//        .navigationBarHidden(true)
//        .edgesIgnoringSafeArea([.top])
//        .sheet(item: self.$selectedModel, onDismiss: {
//            self.selectedModel = nil
//        }) { (row)  in
//            TxDetailsWrapper(row: row)
//        }
//
//    }
//
//    
//}
//
//struct WalletDetails_Previews: PreviewProvider {
//    static var previews: some View {
//        return WalletDetails(viewModel: WalletDetailsViewModel(), isActive: .constant(true))
//    }
//}

class MockWalletDetailViewModel: WalletDetailsViewModel {
    
    override init() {
        super.init()
        
    }
    
}

extension DetailModel {
    static var mockDetails: [DetailModel] {
        var items =  [DetailModel]()
       
            items.append(contentsOf:
                [
                    
                    DetailModel(
                        id: "bb031",
                        arrrAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Date(),
                        arrrAmount: -2.345,
                        status: .paid(success: true),
                        subtitle: "Sent 11/18/19 4:12pm"
                        
                    ),
                    
                    
                    DetailModel(
                        id: "bb032",
                        arrrAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Calendar.current.date(byAdding: .day, value: -1, to: Date())!,
                        arrrAmount: 0.011,
                        status: .received,
                        subtitle: "Received 11/18/19 4:12pm"
                        
                    ),
                    

                    DetailModel(
                        id: "bb033",
                        arrrAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Calendar.current.date(byAdding: .day, value: -2, to: Date())!,
                        arrrAmount: 0.002,
                        status: .paid(success: false),
                        subtitle: "Sent 11/18/19 4:12pm"
                    ),

                    DetailModel(
                        id: "bb034",
                        arrrAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Date(),
                        arrrAmount: -1.345,
                        status: .paid(success: true),
                        subtitle: "Sent 11/15/19 3:12pm"
                        
                    ),
                    
                    
                    DetailModel(
                        id: "bb035",
                        arrrAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Calendar.current.date(byAdding: .day, value: -4, to: Date())!,
                        arrrAmount: 0.022,
                        status: .received,
                        subtitle: "Received 11/18/20 4:12pm"
                        
                    ),
                    

                    DetailModel(
                        id: "bb036",
                        arrrAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                        arrrAmount: 0.012,
                        status: .paid(success: false),
                        subtitle: "Sent 12/18/19 4:12pm"
                    ),
                    
                    
                    DetailModel(
                        id: "bb036",
                        arrrAddress: "Ztestsapling1ctuamfer5xjnnrdr3xdazenljx0mu0gutcf9u9e74tr2d3jwjnt0qllzxaplu54hgc2tyjdc2p6",
                        date: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
                        arrrAmount: 0.012,
                        status: .paid(success: false),
                        subtitle: "Sent 12/18/19 4:12pm"
                    )
                ]
            )
        
        return items
    }
}


struct TxDetailsWrapper: View {
    @State var row: DetailModel
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        ZStack {
            ARRRBackground().edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 0) {
                TransactionDetails(detail: row)
                    .ARRRNavigationBar(leadingItem: {
                       EmptyView()
                    }, headerItem: {
                        HStack{
                            Text("Transaction Details".localized())
                                .font(.barlowRegular(size: Device.isLarge ? 26 : 14)).foregroundColor(Color.zSettingsSectionHeader)
                                .frame(alignment: Alignment.center)
                        }
                    }, trailingItem: {
                        ARRRCloseButton(action: {
                            presentationMode.wrappedValue.dismiss()
                            }).frame(width: 30, height: 30)
                    })
            }
            .padding(.top, 20)
        }
    }
}
