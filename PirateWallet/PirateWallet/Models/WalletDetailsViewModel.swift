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
    @Published var items = [DetailModel]()

    var showError = false
    var balance: Double = 0

    private var synchronizerEvents = Set<AnyCancellable>()
    private var internalEvents = Set<AnyCancellable>()
    @State var showMockData = false // Change it to false = I have used it for mock data testing
    var synchronizer : SDKSynchronizer?

    var combineSDKSynchronizer : CombineSDKSynchronizer?

    let appDelegate: AppDelegate = PirateWalletApp().appDelegate
    
    func groupedTransactions(_ details: [DetailModel]) -> [Date: [DetailModel]] {
      let empty: [Date: [DetailModel]] = [:]
      return details.reduce(into: empty) { acc, cur in
          let components = Calendar.current.dateComponents([.year, .month, .day], from: cur.date)
          let date = Calendar.current.date(from: components)!
          let existing = acc[date] ?? []
          acc[date] = existing + [cur]
      }
    }

    var groupedByDate: [Date: [DetailModel]] {
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
    
    deinit {
        unsubscribeFromSynchonizerEvents()
    }

    func getSortedItems()-> [DetailModel]{
        return self.items.sorted(by: { $0.date > $1.date })
    }
    
    func subscribeToSynchonizerEvents() {
        
//        combineSDKSynchronizer?.allTransactions
//            .receive(on: RunLoop.main)
//            .sink(receiveValue: { [weak self] (d) in
//                self?.items = self!.showMockData ? DetailModel.mockDetails : d
//            })
//            .store(in: &synchronizerEvents)
        
//        combineSDKSynchronizer.balance
//            .receive(on: RunLoop.main)
//            .sink(receiveValue: { [weak self] (b) in
//                self?.balance = b
//            })
//            .store(in: &synchronizerEvents)
    }
    
    func unsubscribeFromSynchonizerEvents() {
        synchronizerEvents.forEach { (c) in
            c.cancel()
        }
        synchronizerEvents.removeAll()
    }
    
    var shieldedBalance: String {
//        return try! PirateAppSynchronizer.shared.appDelegate.sharedSynchronizer.getShieldedBalance().decimalString()
        "shieldedBalance"
    }
    
    var verifiedBalance: String {
//        return try! PirateAppSynchronizer.shared.appDelegate.sharedSynchronizer.getShieldedVerifiedBalance().decimalString()
        "verifiedBalance"
    }
    
    var zAddress: String {
//        ZECCWalletEnvironment.shared.getShieldedAddress() ?? ""
        "--"
    }
}
