//
//  HomeViewModel.swift
//  PirateWallet
//
//  Created by Lokesh on 28/09/24.
//

import SwiftUI
import Combine
import PirateLightClientKit
import LocalAuthentication
import AlertToast
import MnemonicSwift

final class HomeViewModel: ObservableObject {
    enum OverlayType {
        case feedback
        case autoShieldingNotice
        case shieldNowDialog
        case autoShielding
    }
    enum ModalDestinations: Identifiable {
        case profile
        case receiveFunds
        case feedback(score: Int)
        case sendMoney
        
        var id: Int {
            switch self {
            case .profile:
                return 0
            case .receiveFunds:
                return 1
            case .feedback:
                return 2
            case .sendMoney:
                return 3
            }
        }
    }
    
    enum PushDestination {
        case send
        case history
        case balance
    }
    
    
    var isFirstAppear = true
    let genericErrorMessage = "An error ocurred, please check your device logs".localized()
    var sendZecAmount: Double {
        zecAmountFormatter.number(from: sendZecAmountText)?.doubleValue ?? 0.0
    }
    var diposables = Set<AnyCancellable>()
    @Published var transactions: [TransactionDetailModel] = []
//    var items = [TransactionDetailModel]()
    var balance: Double = 0
    @Published var destination: ModalDestinations?
    @Published var sendZecAmountText: String = "0"
    @Published var isSyncing: Bool = false
    @Published var sendingPushed: Bool = false
    @Published var openQRCodeScanner: Bool
    @Published var showError: Bool = false
    @Published var showHistory = false
    @Published var syncStatus: SyncStatus = .upToDate
    @Published var totalBalance: Double = 0
    @Published var verifiedBalance: Double = 0
    @Published var shieldedBalance = ReadableBalance.zero
    @Published var transparentBalance = ReadableBalance.zero
    @Published var showLowSpaceAlert: Bool = false
    private var synchronizerEvents = Set<AnyCancellable>()
    @Published var unifiedAddressObject: UnifiedAddress?
    @Published var arrrAddress: String?

    @Published var overlayType: OverlayType? = nil
    @Published var isOverlayShown = false
    @Published var pushDestination: PushDestination?
    var lastError: UserFacingErrors?
    @Published var syncingInProgress: Float?
    var progress = CurrentValueSubject<Float,Never>(0)
    var pendingTransactions: [DetailModel] = []
    private var cancellable = [AnyCancellable]()
    private var environmentCancellables = [AnyCancellable]()
    private var zecAmountFormatter = NumberFormatter.zecAmountFormatter
    var qrCodeImage: Image?
    @Published var balanceStatus: BalanceStatus?
    
    @Published var aSyncTitleStatus: String?
    

    init() {
        self.destination = nil
        openQRCodeScanner = false
        bindToEnvironmentEvents()
        syncingInProgress = 0.0
        aSyncTitleStatus = ""
        
        NotificationCenter.default.publisher(for: .sendFlowStarted)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.unbindSubcribedEnvironmentEvents()
            }
            ).store(in: &cancellable)
        
        NotificationCenter.default.publisher(for: .sendFlowClosed)
            .receive(on: RunLoop.main)
            .sink(receiveValue: { [weak self] _ in
                self?.sendZecAmountText = ""
                self?.sendingPushed = false
                self?.bindToEnvironmentEvents()
            }
            ).store(in: &cancellable)
        
        
        Task { @MainActor in
            if let aSynchronizer = PirateAppSynchronizer.shared.synchronizer  {
                aSynchronizer.stateStream
                    .throttle(for: .seconds(0.2), scheduler: DispatchQueue.main, latest: true)
                    .sink(receiveValue: { [weak self] state in self?.synchronizerStateUpdatedHome(state) })
                    .store(in: &cancellable)
                
            }
        }
        
        
        Task { @MainActor in
            if let aSynchronizer = PirateAppSynchronizer.shared.synchronizer  {
                aSynchronizer.eventStream
                    .throttle(for: .seconds(0.2), scheduler: DispatchQueue.main, latest: true)
                    .sink(receiveValue: { [weak self] events in self?.synchronizerStateUpdatedEvents(events) })
                    .store(in: &cancellable)
                
                
                aSynchronizer.eventStream
                    .sink(
                        receiveValue: { [weak self] event in
                            
                            printLog("WE ARE HERE")
                            
                            switch event {
                            case let .minedTransaction(transaction):
                                printLog("FOUND MINDED TRANSACTION")

                            case let .foundTransactions(transactions, _):
                                printLog("FOUND ALL TRANSACTION")

                            case .storedUTXOs, .connectionStateChanged:
                                break
                            }
                        }
                    )
                    .store(in: &cancellable)
                
            }
        }
        
        
        balanceStatus = .none
  
        syncBalanceOnUI()
        
        if let aSynchronizer = PirateAppSynchronizer.shared.synchronizer  {
            
            // Fetching pending ones
//            Task { @MainActor in
//                let dataSource =   TransactionsDataSource(
//                    status: .all,
//                    synchronizer: aSynchronizer
//                )
//                try? await dataSource.load()
//                printLog("dataSource.all.count : \(dataSource.transactions.count)")
//            }
//
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                
                Task { @MainActor in
                    let dataSource =   TransactionsDataSource(
                        status: .all,
                        synchronizer: aSynchronizer
                    )
                    
//                    try? await dataSource.load()
//                    self.transactions = dataSource.transactions
                    printLog("TEMPORARY COMMENTED TODO")
                    printLog("dataSource.all.count : \(dataSource.transactions.count)")
                    
                    
                }
                
            }
            
            
            
            PirateAppSynchronizer.shared.combineSdkSynchronizer?.allTransactions
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { (completion) in
                    printLog("ALL TRANSACTIONS HERE")
                }) { [weak self] (allTransactions) in
                    printLog("<<<>>><<ALL TRANSACTIONS HERE>>>><<<")
                            printLog(allTransactions)
                    
                    for transaction in allTransactions {
                        Task { @MainActor in
                            let memos = try await aSynchronizer.getMemos(for: transaction)
                            self?.transactions.append(TransactionDetailModel(transaction: transaction, memos: memos))
                        }
                    }
                    
                    self?.syncBalanceOnUI()
                    
                }.store(in: &cancellable)
            
            
                aSynchronizer.eventStream
                    .map { event in
                        printLog("eventStream")
                        switch(event){
                        case let .foundTransactions(transaction,range):
                            printLog(transaction)
                                return transaction
                        case .minedTransaction(_):
                            printLog("Mined transactions")
                        case .storedUTXOs(_, _):
                            printLog("storedUTXOs")
                        case .connectionStateChanged(_):
                            printLog("connectionStateChanged")
                        default:
                            printLog("Event empty")
                        }
                        
                        return nil
                    }
                    .compactMap { $0 }
                    .receive(on: DispatchQueue.main)
                    .sink(
                        receiveValue: { transaction in
                            printLog("FOUND SOME TRANSACTIONS")
                            printLog(transaction) }
                    )
                    .store(in: &environmentCancellables)
            
            
//            // Fetching sent ones
//            Task { @MainActor in
//                let dataSource =   TransactionsDataSource(
//                    status: .received,
//                    synchronizer: aSynchronizer
//                )
//                
//                do {
//                    try await dataSource.load()
//                    printLog("dataSource.sent.count : \(dataSource.transactions.count)")
//                    await initTransactions()
//                }catch{
//                    printLog(error)
//                }
//                
//            }
            
        }
        
//        NotificationCenter.default.publisher(for: .syncingInProgress)
//            .receive(on: RunLoop.main)
//            .sink(receiveValue: { [weak self] _ in
//                self?.syncingInProgress = PirateAppSynchronizer.shared.currentProgress
//            }
//            ).store(in: &cancellable)
        
//        NotificationCenter.default.publisher(for: .syncingFinished)
//            .receive(on: RunLoop.main)
//            .sink(receiveValue: { [weak self] _ in
//                self?.syncingInProgress = 100
//            }
//            ).store(in: &cancellable)
        
        
        NotificationCenter.default.publisher(for: .qrCodeScanned)
                   .receive(on: DispatchQueue.main)
                   .debounce(for: 1, scheduler: RunLoop.main)
                   .sink(receiveCompletion: { (completion) in
                       switch completion {
                       case .failure(let error):
                           printLog("error scanning: \(error)")

                       case .finished:
                           printLog("finished scanning")
                       }
                   }) { (notification) in
                       guard let address = notification.userInfo?["zAddress"] as? String else {
                           return
                       }
                       self.openQRCodeScanner = false
                       printLog("got address \(address)")
                       
               }
               .store(in: &diposables)
        
//        subscribeToSynchonizerEvents()
        
        Task { @MainActor in
            do {
                try await generateQRCodeImage()
            }catch{
                printLog(error)
            }
            
            do {
                try await self.getUnifiedAddress()
            }catch{
                printLog(error)
            }
            
        }
    }
    
    func initTransactions() async {
        printLog("PRINTING TS")
        if let aSynchronizer = PirateAppSynchronizer.shared.synchronizer  {
            await printLog(aSynchronizer.pendingTransactions.count)
            await printLog(aSynchronizer.sentTransactions.count)
            await printLog(aSynchronizer.receivedTransactions.count)
            
            
        }
        
    }
    
    func syncBalanceOnUI(){
        
        Task { @MainActor in
            
            if let aSynchronizer = PirateAppSynchronizer.shared.synchronizer  {
                
                verifiedBalance = try! await aSynchronizer.getShieldedVerifiedBalance().decimalValue.doubleValue
                printLog("verifiedBalance : \(verifiedBalance)")
                let shieldedBalance = try! await aSynchronizer.getShieldedBalance().decimalValue.doubleValue
                printLog("balance : \(shieldedBalance)")
//                let transparentBalanc = try! await aSynchronizer.getTransparentBalance(accountIndex: 0).verified.decimalValue.int64Value
//                printLog("transparentBalanc : \(transparentBalanc)")
//                let transparentBalanceTotal = try! await aSynchronizer.getTransparentBalance(accountIndex: 0).total.decimalValue.int64Value
//                printLog("transparentBalanceTotal : \(transparentBalanceTotal)")
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
    
    deinit {
//        unsubscribeFromSynchonizerEvents()
        unbindSubcribedEnvironmentEvents()
        cancellable.forEach { $0.cancel() }
    }
    
//    func subscribeToSynchonizerEvents() {
//
//        ZECCWalletEnvironment.shared.synchronizer.walletDetailsBuffer
//            .receive(on: RunLoop.main)
//            .sink(receiveValue: { [weak self] (d) in
//                self?.items = d
//            })
//            .store(in: &synchronizerEvents)
//
//        ZECCWalletEnvironment.shared.synchronizer.balance
//            .receive(on: RunLoop.main)
//            .sink(receiveValue: { [weak self] (b) in
//                self?.balance = b
//            })
//            .store(in: &synchronizerEvents)
//    }
    
    private func synchronizerStateUpdatedEvents(_ events: SynchronizerEvent) {
        printLog(">>>>>>>><<<<<<<<<<")
        printLog("synchronizerStateUpdatedEvents")
        switch(events){
        case let .foundTransactions(transaction,range):
            printLog("FOUND transactions")
            printLog(transaction)
        case .minedTransaction(_):
            printLog("Mined transactions")
        case .storedUTXOs(_, _):
            printLog("storedUTXOs")
        case .connectionStateChanged(_):
            printLog("connectionStateChanged")
        default:
            printLog("Event empty")
        }
        
        printLog(">>>>>>>>_________<<<<<<<<<<")
    }
    
    private func synchronizerStateUpdatedHome(_ state: SynchronizerState) {
        printLog("Logging inside HomeViewModel.synchronizerStateUpdatedHome")
        printLog(state.syncStatus)
        switch state.syncStatus {
        case .error:
            NotificationCenter.default.post(name: NSNotification.Name(mStopSoundOnceFinishedOrInForeground), object: nil)
            aSyncTitleStatus = "Retrying"
        case .unprepared:
            aSyncTitleStatus = ""
        case .syncing(let downloadingProgress):
            if downloadingProgress == 0 {
                NotificationCenter.default.post(name: NSNotification.Name(mPlaySoundWhileSyncing), object: nil)
            }else if downloadingProgress == 100 {
                NotificationCenter.default.post(name: NSNotification.Name(mStopSoundOnceFinishedOrInForeground), object: nil)
            }
        
            let currentProgress = (floor(downloadingProgress * 1000)) / 10
            
            aSyncTitleStatus = "Syncing".localized() + " " + currentProgress.description + " %"

        case .upToDate:
            NotificationCenter.default.post(name: NSNotification.Name(mStopSoundOnceFinishedOrInForeground), object: nil)
            aSyncTitleStatus = "Synced 100%".localized()
        }
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
    
    
    func generateQRCodeImage() async throws{
            
        guard let uAddress = try? await PirateAppSynchronizer.shared.synchronizer?.getUnifiedAddress(accountIndex: 0) else {
            printLog("could not derive UA")
            printLog("could not derive tAddress")
            printLog("could not derive zAddress")
            return
        }
        
        let arrrSheildedAddress = try? uAddress.saplingReceiver().stringEncoded
        
            if let img = QRCodeGenerator.generate(from: arrrSheildedAddress ?? "") {
               qrCodeImage = Image(img, scale: 1, label: Text(String(format:NSLocalizedString("QR Code for %@", comment: ""),"\(arrrSheildedAddress)") ))
           } else {
               qrCodeImage = Image("QRCodeIcon")
           }
    }
    
//    func unsubscribeFromSynchonizerEvents() {
//        synchronizerEvents.forEach { (c) in
//            c.cancel()
//        }
//        synchronizerEvents.removeAll()
//    }
//
    func getSortedItems()-> [TransactionDetailModel]{
        if self.transactions.count == 0 {
            return []
        }
        
        return self.transactions.sorted(by: {
            
            $0.created ?? Date() > $1.created ?? Date()   // TODO: Supplying a dummy date for sorting as it was leading to crash for newly created sent transaction
            
        })
    }
    
    func bindToEnvironmentEvents() {
//        let environment = PirateAppSynchronizer.shared
//        
//        environment.synchronizer.transparentBalance
//            .receive(on: DispatchQueue.main)
//            .map({ return ReadableBalance(walletBalance: $0) })
//            .assign(to: \.transparentBalance, on: self)
//            .store(in: &environmentCancellables)
//        
//        environment.synchronizer.shieldedBalance
//            .receive(on: DispatchQueue.main)
//            .map({ return ReadableBalance(walletBalance: $0) })
//            .assign(to: \.shieldedBalance, on: self)
//            .store(in: &environmentCancellables)
//        
//        
//        environment.synchronizer.errorPublisher
//            .receive(on: DispatchQueue.main)
//            .map( ZECCWalletEnvironment.mapError )
//            .map(trackError)
//            .map(mapToUserFacingError)
//            .sink { [weak self] error in
//                guard let self = self else { return }
//                
//                self.show(error: error)
//            }
//            .store(in: &environmentCancellables)
//        
//        environment.synchronizer.pendingTransactions
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { (completion) in
//                
//            }) { [weak self] (pendingTransactions) in
//                self?.pendingTransactions = pendingTransactions.filter({ $0.minedHeight == BlockHeight.unmined && $0.errorCode == nil })
//                    .map( { DetailModel(pendingTransaction: $0)})
//            }.store(in: &cancellable)
//        
//        environment.synchronizer.syncStatus
//            .receive(on: DispatchQueue.main)
//            .map({ $0.isSyncing })
//            .removeDuplicates()
//            .map({ status in
//                // Issue 286: Force the app to be awake while syncing
//                if status {
//                    printLog("--SHOULD NOT SLEEP--")
//                    UIApplication.shared.isIdleTimerDisabled = true
//                } else {
//                    printLog("--SHOULD SLEEP 💤😴--")
//                    UIApplication.shared.isIdleTimerDisabled = false
//                }
//                return status
//            })
//            .assign(to: \.isSyncing, on: self)
//            .store(in: &environmentCancellables)
//        
//        environment.synchronizer.syncStatus
//            .receive(on: DispatchQueue.main)
//            .assign(to: \.syncStatus, on: self)
//            .store(in: &environmentCancellables)
//        
//        environment.synchronizer.syncStatus
//            .filter({ $0 == .synced})
//            .first()
//            .compactMap({ [weak environment] status -> OverlayType? in
//                Session.unique.markFirstSync()
//                guard let env = environment else { return nil }
//                
//                if env.shouldShowAutoShieldingNotice {
//                    return OverlayType.autoShieldingNotice
//                } else if env.autoShielder.strategy.shouldAutoShield {
//                    return OverlayType.shieldNowDialog
//                }
//                return nil
//            })
//            .receive(on: DispatchQueue.main)
//            .sink { overlay in
//                self.overlayType = overlay
//                self.isOverlayShown = true
//            }
//            .store(in: &cancellable)
//                        
//        environment.synchronizer.walletDetailsBuffer
//                .receive(on: RunLoop.main)
//                .sink(receiveValue: { [weak self] (d) in
//                    self?.items = d
//                })
//                .store(in: &environmentCancellables)
//
//        environment.synchronizer.balance
//            .receive(on: RunLoop.main)
//            .sink(receiveValue: { [weak self] (b) in
//                self?.balance = b
//            })
//            .store(in: &environmentCancellables)
    }
    
    func unbindSubcribedEnvironmentEvents() {
        environmentCancellables.forEach { $0.cancel() }
        environmentCancellables.removeAll()
    }
    
    
    func show(error: UserFacingErrors) {
        self.lastError = error
        self.showError = true
    }
    
    func clearError() {
        self.lastError = nil
        self.showError = false
    }
    
    var lowSpaceAlert: Alert {
         
        return Alert(title: Text("Low space"),
                     
                     message: Text("Low space message here"),
                     dismissButton: .default(Text("button_close".localized()),
                                         action: nil))
    }
    
//    var errorAlert: Alert {
//        let errorAction = {
//            self.clearError()
//        }
//        
//        guard let error = lastError else {
//            return Alert(title: Text("Error".localized()), message: Text(genericErrorMessage), dismissButton: .default(Text("button_close".localized()),action: errorAction))
//        }
//        
//        
//        let defaultAlert = Alert(title: Text(error.title),
//
//                                message: Text(error.message),
//                                dismissButton: .default(Text("button_close".localized()),
//                                                    action: errorAction))
//
//        switch error {
//        case .synchronizerError(let canRetry):
//            if canRetry {
//                return Alert(
//                        title: Text(error.title),
//                        message: Text(error.message),
//                        primaryButton: .default(Text("button_close".localized()),action: errorAction),
//                        secondaryButton: .default(Text("Retry".localized()),
//                                                     action: {
//                                                        self.clearError()
//                                                        try? ZECCWalletEnvironment.shared.synchronizer.start(retry: true)
//                                                        })
//                           )
//
//            } else {
//                return defaultAlert
//            }
//        default:
//            return defaultAlert
//        }
//    }
    
    func setAmount(_ zecAmount: Double) {
        guard let value = self.zecAmountFormatter.string(for: zecAmount - PirateSDKMainnetConstants.defaultFee().decimalValue.doubleValue) else { return }
        self.sendZecAmountText = value
    }
    
    
    func setAmountWithoutFee(_ zecAmount: Double) {
        guard let value = self.zecAmountFormatter.string(for: zecAmount) else { return }

//        guard let value = self.zecAmountFormatter.string(for: zecAmount - ZCASH_NETWORK.constants.defaultFee().asHumanReadableZecBalance()) else { return }

        self.sendZecAmountText = value
    }
    
    
    func retrySyncing() {
//        do {
            PirateAppSynchronizer.shared.startStop()
//        } catch {
//            self.lastError = mapToUserFacingError(ZECCWalletEnvironment.mapError(error: error))
//        }
    }
    
}
