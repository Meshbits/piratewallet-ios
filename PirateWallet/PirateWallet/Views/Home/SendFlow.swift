//
//  SendFlow.swift
//  PirateWallet
//
//  Created by Lokesh on 27/11/24.
//

import Foundation
import Combine
import SwiftUI
import PirateLightClientKit

class SendFlow {
    
    static var current: SendFlowEnvironment?
    static var verifiedBalance: Int64 = 0
    
    static func end() {
        guard let current = self.current else {
            return
        }
        
        current.close()
        
        Self.current = nil
    }
    
    @discardableResult static func start(
                      isActive: Binding<Bool>,
                      amount: Double,memoText: String,address: String) -> SendFlowEnvironment {

        let flow = SendFlowEnvironment(amount: amount,
                                       verifiedBalance: Double(verifiedBalance),
                                       isActive: isActive)
        Self.current = flow
        
        if !memoText.isEmpty {
            flow.memo = memoText
        }
        
        if !address.isEmpty {
            flow.address = address
        }
        
        NotificationCenter.default.post(name: .sendFlowStarted, object: nil)
        return flow
    }
}


final class SendFlowEnvironment: ObservableObject {
    enum FlowState {
        case preparing
        case downloadingParameters
        case sending
        case finished
        case failed(error: UserFacingErrors)
    }
    static let maxMemoLength: Int = PirateAppConfig.memoLengthLimit
    enum FlowError: Error {
        case invalidEnvironment
        case duplicateSent
        case invalidAmount(message: String)
        case derivationFailed(error: Error)
        case derivationFailed(message: String)
        case invalidDestinationAddress(address: String)
    }
    
    @Published var showScanView = false
    @Published var amount: String
    @Binding var isActive: Bool
    @Published var address: String
    @Published var verifiedBalance: Double
    @Published var memo: String = ""
    @Published var includesMemo = false
    @Published var includeSendingAddress: Bool = false
    @Published var isDone = false
    @Published var state: FlowState = .preparing
    var txSent = false

    var error: Error?
    var showError = false
    var diposables = Set<AnyCancellable>()
    
    fileprivate init(amount: Double, verifiedBalance: Double, address: String = "", isActive: Binding<Bool>) {
        self.amount = NumberFormatter.zecAmountFormatter.string(from: NSNumber(value: amount)) ?? ""
        if amount == 0 {
            self.amount = ""
        }
        self.verifiedBalance = verifiedBalance
        self.address = address
        self._isActive = isActive
        
        NotificationCenter.default.publisher(for: .qrZaddressScanned)
                   .receive(on: DispatchQueue.main)
                   .debounce(for: 1, scheduler: RunLoop.main)
                   .sink(receiveCompletion: { (completion) in
                       switch completion {
                       case .failure(let error):
                           printLog("error scanning: \(error)")
                           self.error = error
                       case .finished:
                           printLog("finished scanning")
                       }
                   }) { (notification) in
                       guard let address = notification.userInfo?["zAddress"] as? String else {
                           return
                       }
                       self.showScanView = false
                       printLog("got address \(address)")
                       self.address = address.trimmingCharacters(in: .whitespacesAndNewlines)
                       
               }
               .store(in: &diposables)
    }
    
    deinit {
        diposables.forEach { d in
            d.cancel()
        }
    }

    func clearMemo() {
        self.memo = ""
        self.includeSendingAddress = false
        self.includesMemo = false
    }

    func fail(_ error: Error) {
        self.error = error
        self.showError = true
        self.isDone = true
        self.state = .failed(error: mapToUserFacingError(.sendFailed(error: error)))
    }
    
    func spendParamsURLHelper() throws -> URL {
        try documentsDirectoryHelper().appendingPathComponent("sapling-spend.params")
    }

    func outputParamsURLHelper() throws -> URL {
        try documentsDirectoryHelper().appendingPathComponent("sapling-output.params")
    }

    
    func preSend() {
        guard case FlowState.preparing = self.state else {
            let message = "attempt to start a pre-send stage where status was not .preparing and was \(self.state) instead"
            printLog(message)
            fail(FlowError.duplicateSent)
            return
        }
        
        self.state = .downloadingParameters
        let outputParameter = try! outputParamsURLHelper()
        let spendParameter = try! spendParamsURLHelper()
        var loggerProxy = OSLogger(logLevel: .debug)
        
        Task { @MainActor in
            do {
                let urls = try await SaplingParameterDownloader.downloadParamsIfnotPresent(
                    spendURL: spendParameter,
                    spendSourceURL: SaplingParamsSourceURL.default.spendParamFileURL,
                    outputURL: outputParameter,
                    outputSourceURL: SaplingParamsSourceURL.default.outputParamFileURL,
                    logger: loggerProxy
                )
                
                self.send()
                
            } catch {
                self.state = .failed(error: .connectionFailed)
                self.fail(error)
            }
        }
        
    }
    
    func isBalanceValid() async -> Bool {

        if let aSynchronizer = PirateAppSynchronizer.shared.synchronizer  {
                let balanceText = (try? await aSynchronizer.getShieldedBalance().decimalString()) ?? "0.0"
                let verifiedText = (try? await aSynchronizer.getShieldedVerifiedBalance().decimalString()) ?? "0.0"
                let balance = try? await PirateAppSynchronizer.shared.synchronizer?.getShieldedBalance() ?? .zero
                return balance ?? .zero > .zero
        }else{
            return false
        }
        
    }
    
    func isAmountValid() async -> Bool {
        
        if let aSynchronizer = PirateAppSynchronizer.shared.synchronizer  {
                let balance = (try? await aSynchronizer.getShieldedVerifiedBalance(accountIndex: 0)) ?? .zero
                guard
                    let amountValue = NumberFormatter.zcashNumberFormatter.number(from: amount).flatMap({ Zatoshi($0.int64Value) }),
                    amountValue <= balance
                else {
                    return false
                }

        }else{
            return false
        }

        return true
    }

    
    func isRecipientValid() -> Bool {
        if address.count > 0 {
            return address.isValidShieldedAddress || address.isValidTransparentAddress
        }else{
            return false
        }
    }
    
    func isFormValid() async -> Bool {
        switch PirateAppSynchronizer.shared.closureSynchronizer?.latestState.syncStatus {
        case .upToDate:
            let isBalanceValid = await self.isBalanceValid()
            let isAmountValid = await self.isAmountValid()
            return isBalanceValid && isAmountValid && isRecipientValid()
        default:
            return false
        }
    }
    
    func send() {
        guard !txSent else {
            let message = "attempt to send tx twice".localized()
            printLog(message)
            fail(FlowError.duplicateSent)
            return
        }
        self.state = .sending
        
        Task { @MainActor in
            guard
                await isFormValid()
            else {
                printLog("WARNING: Form is invalid")
                return
            }

            let derivationTool = DerivationTool(networkType: kPirateNetwork.networkType)
            guard let spendingKey = try? derivationTool.deriveUnifiedSpendingKey(seed: PirateAppConfig.defaultSeed, accountIndex: 0) else {
                printLog("NO SPENDING KEY")
                return
            }
            
            guard let zatoshi = doubleAmount?.toZatoshi() else {
                let message = "invalid arrr amount:".localized() + " \(String(describing: doubleAmount))"
                printLog(message)
                fail(FlowError.invalidAmount(message: message))
                return
            }

            /// TODO: SHOW LOADER


            if let aSynchronizer = PirateAppSynchronizer.shared.synchronizer  {
                
                do {
                    let pendingTransaction = try await aSynchronizer.sendToAddress(
                        spendingKey: spendingKey,
                        zatoshi: Zatoshi(zatoshi),
                        // swiftlint:disable:next force_try
                        toAddress: try! Recipient(address, network: kPirateNetwork.networkType),
                        // swiftlint:disable:next force_try
                        memo:  Memo(string: memo)
                    )
                    /// TODO: HIDE LOADER
                    printLog("transaction created: \(pendingTransaction)")
                    // fix me:
                    self.isDone = true
                    self.state = .finished
                
                    UserSettings.shared.lastUsedAddress = self.address
                   
                    self.txSent = true
                } catch {
                    fail(error)
                    printLog("SEND FAILED: \(error)")
                }
             }
            
          
        }
        
           
    }
    
    var hasErrors: Bool {
        self.error != nil || self.showError
    }
    var hasFailed: Bool {
        isDone && hasErrors
    }
    
    var hasSucceded: Bool {
        isDone && !hasErrors
    }
    var doubleAmount: Double? {
        NumberFormatter.zecAmountFormatter.number(from: self.amount)?.doubleValue
    }
    func close() {
        self.isActive = false
        NotificationCenter.default.post(name: .sendFlowClosed, object: nil)
    }
    
    static func replyToAddress(_ address: String) -> String {
        "\nReply-To: \(address)"
    }
    
    static func includeReplyTo(address: String, in memo: String, charLimit: Int = SendFlowEnvironment.maxMemoLength) throws -> String {
        
        let replyTo = replyToAddress(address)
        
        if (memo.count + replyTo.count) >= charLimit {
            let truncatedMemo = String(memo[memo.startIndex ..< memo.index(memo.startIndex, offsetBy: (memo.count - replyTo.count))])
            
            return truncatedMemo + replyTo
        }
        return memo + replyTo
        
    }
    
    static func buildMemo(memo: String, includesMemo: Bool, replyToAddress: String?) throws -> String? {
        
        guard includesMemo else { return nil }
        
        if let addr = replyToAddress {
            return try includeReplyTo(address: addr, in: memo)
        }
        guard !memo.isEmpty else { return nil }
        
        guard !memo.isEmpty else { return nil }
        
        return memo
       
    }
}
