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
    @Published var items = [DetailModel]()
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
//    private var synchronizerEvents = Set<AnyCancellable>()

    @Published var overlayType: OverlayType? = nil
    @Published var isOverlayShown = false
    @Published var pushDestination: PushDestination?
    var lastError: UserFacingErrors?

    var progress = CurrentValueSubject<Float,Never>(0)
    var pendingTransactions: [DetailModel] = []
    private var cancellable = [AnyCancellable]()
    private var environmentCancellables = [AnyCancellable]()
    private var zecAmountFormatter = NumberFormatter.zecAmountFormatter
    var qrCodeImage: Image?

    init() {
        self.destination = nil
        openQRCodeScanner = false
        bindToEnvironmentEvents()
        
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
    
    func generateQRCodeImage() async throws{
            
        guard let uAddress = try? await PirateAppSynchronizer.shared.synchronizer?.getUnifiedAddress(accountIndex: 0) else {
            printLog("could not derive UA")
            printLog("could not derive tAddress")
            printLog("could not derive zAddress")
            return
        }
        
        let arrrSheildedAddress = uAddress.stringEncoded
        
           if let img = QRCodeGenerator.generate(from: arrrSheildedAddress) {
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
    func getSortedItems()-> [DetailModel]{
        return self.items.sorted(by: { $0.date > $1.date })
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
