//
//  WalletDetailsViewModel.swift
//  PirateWallet
//
//  Created by Lokesh on 23/09/24.
//

import SwiftUI
import Combine

import PirateLightClientKit

class WalletDetailsViewModel: ObservableObject {
    // look at before changing https://stackoverflow.com/questions/60956270/swiftui-view-not-updating-based-on-observedobject
    @Published var items = [TransactionDetailModel]()

    var showError = false
    @Published var totalBalance: Double = 0
    @Published var verifiedBalance: Double = 0
    @Published var shieldedBalance = ReadableBalance.zero
    @Published var transparentBalance = ReadableBalance.zero
    
    private var synchronizerEvents = Set<AnyCancellable>()
    private var internalEvents = Set<AnyCancellable>()
    @State var showMockData = false // Change it to false = I have used it for mock data testing
    var synchronizer : SDKSynchronizer?
    @Published var balanceStatus: BalanceStatus?
    var combineSDKSynchronizer : CombineSDKSynchronizer?
    private var cancellable = [AnyCancellable]()
    let appDelegate: AppDelegate = PirateWalletApp().appDelegate
    @Published var unifiedAddressObject: UnifiedAddress?
    @Published var arrrAddress: String?

    func groupedTransactions(_ details: [TransactionDetailModel]) -> [Date: [TransactionDetailModel]] {
      let empty: [Date: [TransactionDetailModel]] = [:]
      return details.reduce(into: empty) { acc, cur in
          let components = Calendar.current.dateComponents([.year, .month, .day], from: cur.created!)
          let date = Calendar.current.date(from: components)!
          let existing = acc[date] ?? []
          acc[date] = existing + [cur]
      }
    }

    var groupedByDate: [Date: [TransactionDetailModel]] {
//        Dictionary(grouping: self.items, by: {$0.date})
        groupedTransactions(self.items)
    }
    
    var headers: [Date] {
        groupedByDate.map({ $0.key }).sorted().reversed()
    }

    init(){
        synchronizer = appDelegate.sharedSynchronizer
        combineSDKSynchronizer = CombineSDKSynchronizer(synchronizer: appDelegate.sharedSynchronizer)
         
        subscribeToSynchonizerEvents()
        
    }
    
    func syncTransactions(){
        
        if let aSynchronizer = PirateAppSynchronizer.shared.synchronizer  {
            PirateAppSynchronizer.shared.combineSdkSynchronizer?.allTransactions
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (completion) in
                    printLog("ALL TRANSACTIONS HERE")
                }) { [weak self] (allTransactions) in
                    printLog("<<<>>><<ALL TRANSACTIONS HERE WALLET TAB>>>><<<")
                    printLog(allTransactions)
                    
                    for transaction in allTransactions {
                        Task { @MainActor in
                            let memos = try await aSynchronizer.getMemos(for: transaction)
                            self?.items.append(TransactionDetailModel(transaction: transaction, memos: memos))
                        }
                    }
                    
                    self?.syncBalanceOnUI()
                    
                }.store(in: &cancellable)
            
        }
    }
    
    func syncBalanceOnUI(){
        
        Task { @MainActor in
            
            if let aSynchronizer = PirateAppSynchronizer.shared.synchronizer  {
                
                verifiedBalance = try! await aSynchronizer.getShieldedVerifiedBalance().decimalValue.doubleValue
                printLog("verifiedBalance : \(verifiedBalance)")
                let shieldedBalance = try! await aSynchronizer.getShieldedBalance().decimalValue.doubleValue
                printLog("valid balance : \(shieldedBalance)")
                let difference = verifiedBalance - shieldedBalance
                
                let abs_difference = Double(abs(difference))
                
                printLog("Balance Status")
                printLog(difference)
                                
                if difference == 0 {
                    self.balanceStatus = BalanceStatus.available(showCaption: true)
                }
                else if difference > 0 {
                    self.balanceStatus = BalanceStatus.expecting(arrr: abs_difference)
                }
                else {
                    self.balanceStatus = BalanceStatus.waiting(change: abs_difference)
                }
            }
        }
    }
    
    
    func updateTransactions(transactions: [TransactionDetailModel]){
        self.items = transactions
    }
    
    deinit {
        unsubscribeFromSynchonizerEvents()
    }

    func getSortedItems()-> [TransactionDetailModel]{
        return self.items.sorted(by: { $0.created! > $1.created! })
    }
    
    func subscribeToSynchonizerEvents() {
        syncTransactions()
    }
    
    func unsubscribeFromSynchonizerEvents() {
        synchronizerEvents.forEach { (c) in
            c.cancel()
        }
        synchronizerEvents.removeAll()
    }
        
    
    func getUnifiedAddress() async throws{
        Task { @MainActor in
            if let unifiedAddress = try? await PirateAppSynchronizer.shared.synchronizer?.getUnifiedAddress(accountIndex: 0) {
                self.unifiedAddressObject = unifiedAddress
                
                if let arrrSheildedAddress = try? unifiedAddress.saplingReceiver().stringEncoded {
                    self.arrrAddress = arrrSheildedAddress
                }
                
                
            }
        }
    }
    
}
