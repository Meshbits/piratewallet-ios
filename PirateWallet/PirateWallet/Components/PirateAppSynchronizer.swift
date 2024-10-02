//
//  PirateAppSynchronizer.swift
//  PirateWallet
//
//  Created by Lokesh on 20/09/24.
//

import Foundation
import Combine
import PirateLightClientKit
import SwiftUI
import MnemonicSwift

public class PirateAppSynchronizer : ObservableObject{
    
    static let shared = PirateAppSynchronizer()
    
    var cancellables: [AnyCancellable] = []
    
    private var queue = DispatchQueue(label: "metrics.queue", qos: .default)
    
    private var enhancingStarted = false
    
    private var accumulatedMetrics: ProcessorMetrics = .initial
    
    private var currentMetric: SDKMetrics.Operation?
    
    private var currentMetricName: String {
        guard let currentMetric else { return "" }
        switch currentMetric {
        case .downloadBlocks: return "download: "
        case .validateBlocks: return "validate: "
        case .scanBlocks: return "scan: "
        case .enhancement: return "enhancement: "
        case .fetchUTXOs: return "fetchUTXOs: "
        }
    }
    
    init() {
        initialize()
    }
 
    let dateFormatter = DateFormatter()

    var synchronizer : SDKSynchronizer?

    var closureSynchronizer : ClosureSDKSynchronizer?

    let appDelegate: AppDelegate = PirateWalletApp().appDelegate
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
    
    func initialize() {
        
        synchronizer = appDelegate.sharedSynchronizer
        closureSynchronizer = ClosureSDKSynchronizer(synchronizer: appDelegate.sharedSynchronizer)
          
        if let aSynchronizer = synchronizer  {
            aSynchronizer.stateStream
                .throttle(for: .seconds(0.2), scheduler: DispatchQueue.main, latest: true)
                .sink(receiveValue: { [weak self] state in self?.synchronizerStateUpdated(state) })
                .store(in: &cancellables)
            
        }
        
    }
    
    func stopSynchronization() {
        cancellables.forEach { $0.cancel() }
        if let aClosureSynchronizer = closureSynchronizer  {
            aClosureSynchronizer.stop()
        }
    }
    
    private func synchronizerStateUpdated(_ state: SynchronizerState) {
        self.updateUI()

        switch state.syncStatus {
        case .unprepared:
            UserSettings.shared.currentSyncStatus = LocalSyncStatus.notStarted.rawValue
            break

        case let .syncing(progress):
            enhancingStarted = false
            
//            progressBar.progress = progress
//            progressLabel.text = "\(floor(progress * 1000) / 10)%"
            printLog("\(floor(progress * 1000) / 10)%")
            let syncedDate = dateFormatter.string(from: Date(timeIntervalSince1970: state.latestScannedTime))
            let progressText = """
            synced date         \(syncedDate)
            synced block        \(state.latestScannedHeight)
            latest block height \(state.latestBlockHeight)
            """
//            progressDataLabel.text = progressText
                        
            if state.latestScannedHeight > 0 {
                UserSettings.shared.lastSyncedBlockHeight = state.latestScannedHeight
                UserSettings.shared.currentSyncStatus = LocalSyncStatus.inProgress.rawValue
            }

            printLog(progressText)
//            if let currentMetric {
//                let report = synchronizer.metrics.popBlock(operation: currentMetric)?.last
//                metricLabel.text = currentMetricName + report.debugDescription
//            }

        case .upToDate:
            accumulateMetrics()
            UserSettings.shared.currentSyncStatus = LocalSyncStatus.completed.rawValue
            printLog("enhancement: \(accumulatedMetrics.debugDescription)")
            overallSummary()

        case .error:
            UserSettings.shared.currentSyncStatus = LocalSyncStatus.notStarted.rawValue
            break
        }
    }
    
    
    func accumulateMetrics() {
        guard let currentMetric else { return }
        if let aSynchronizer = synchronizer  {
            if let reports = aSynchronizer.metrics.popBlock(operation: currentMetric) {
                for report in reports {
                    accumulatedMetrics = .accumulate(accumulatedMetrics, current: report)
                }
            }
        }
        
    }
    
    func overallSummary() {
        
        if let aSynchronizer = synchronizer  {
            
            let cumulativeSummary = aSynchronizer.metrics.cumulativeSummary()
            
            let downloadedBlocksReport = cumulativeSummary.downloadedBlocksReport ?? SDKMetrics.ReportSummary.zero
            let validatedBlocksReport = cumulativeSummary.validatedBlocksReport ?? SDKMetrics.ReportSummary.zero
            let scannedBlocksReport = cumulativeSummary.scannedBlocksReport ?? SDKMetrics.ReportSummary.zero
            let enhancementReport = cumulativeSummary.enhancementReport ?? SDKMetrics.ReportSummary.zero
            let fetchUTXOsReport = cumulativeSummary.fetchUTXOsReport ?? SDKMetrics.ReportSummary.zero
            let totalSyncReport = cumulativeSummary.totalSyncReport ?? SDKMetrics.ReportSummary.zero

            printLog(
                """
                Summary:
                    downloadedBlocks: min: \(downloadedBlocksReport.minTime) max: \(downloadedBlocksReport.maxTime) avg: \(downloadedBlocksReport.avgTime)
                    validatedBlocks: min: \(validatedBlocksReport.minTime) max: \(validatedBlocksReport.maxTime) avg: \(validatedBlocksReport.avgTime)
                    scannedBlocks: min: \(scannedBlocksReport.minTime) max: \(scannedBlocksReport.maxTime) avg: \(scannedBlocksReport.avgTime)
                    enhancement: min: \(enhancementReport.minTime) max: \(enhancementReport.maxTime) avg: \(enhancementReport.avgTime)
                    fetchUTXOs: min: \(fetchUTXOsReport.minTime) max: \(fetchUTXOsReport.maxTime) avg: \(fetchUTXOsReport.avgTime)
                    totalSync: min: \(totalSyncReport.minTime) max: \(totalSyncReport.maxTime) avg: \(totalSyncReport.avgTime)
                """)
        }
      
    }
    
    
    func createNewWalletWithPhrase(randomPhrase:String) async throws {
        
        do {
           
            if randomPhrase.isEmpty {
                let mPhrase = try MnemonicSeedProvider.default.randomMnemonic()
                try SeedManager.default.importPhrase(bip39: mPhrase)
            }else{
                try SeedManager.default.importPhrase(bip39: randomPhrase)
            }
            
            let birthday = PirateAppConfig.defaultBirthdayHeight
            
            try SeedManager.default.importBirthday(birthday)
             
            SeedManager.default.importLightWalletEndpoint(address: PirateAppConfig.address)
            SeedManager.default.importLightWalletPort(port: PirateAppConfig.port)
            try await self.initializeFreshWallet()
        
        } catch {
            throw WalletError.createFailed(underlying: error)
        }
    }
    
    func initializeFreshWallet() async throws {
//        let seedPhrase = try SeedManager.default.exportPhrase()
        let derivationTool = DerivationTool(networkType: kPirateNetwork.networkType)
        let defaultSeed = try! Mnemonic.deterministicSeedBytes(from: SeedManager.default.exportPhrase())
        let spendingKey = try! derivationTool
            .deriveUnifiedSpendingKey(seed: defaultSeed, accountIndex: 0)

        let viewingKey =  try! derivationTool.deriveUnifiedFullViewingKey(from: spendingKey)
        
        let initializer = Initializer(
            cacheDbURL: nil,
            fsBlockDbRoot: try! fsBlockDbRootURLHelper(),
            dataDbURL: try! dataDbURLHelper(),
            endpoint: PirateAppConfig.endpoint,
            network: kPirateNetwork,
            spendParamsURL: try! spendParamsURLHelper(),
            outputParamsURL: try! outputParamsURLHelper(),
            saplingParamsSourceURL: SaplingParamsSourceURL.default
        )
        
        self.synchronizer = SDKSynchronizer(initializer: initializer)
        
        try startStopNewWallet(with: defaultSeed, viewingKeys: [viewingKey], walletBirthday: SeedManager.default.exportBirthday())
        
//        _ = try await self.synchronizer?.prepare(with: defaultSeed,viewingKeys: [viewingKey],walletBirthday: SeedManager.default.exportBirthday())
        
    }
    
    
    func startStop() {
        Task { @MainActor in
            await doStartStop()
        }
    }
    
    func startStopNewWallet(with defaultSeed: [UInt8]?,
                            viewingKeys: [UnifiedFullViewingKey],
                            walletBirthday: BlockHeight) {
        Task { @MainActor in
            if let aSynchronizer = synchronizer  {
                aSynchronizer.stateStream
                    .throttle(for: .seconds(0.2), scheduler: DispatchQueue.main, latest: true)
                    .sink(receiveValue: { [weak self] state in self?.synchronizerStateUpdated(state) })
                    .store(in: &cancellables)
                
            }
            await doStartStopNewWallet(with: defaultSeed, viewingKeys: viewingKeys, walletBirthday: walletBirthday)
        }
    }
    
    func doStartStop() async {
        
        if let aSynchronizer = synchronizer  {
            let syncStatus = aSynchronizer.latestState.syncStatus
            switch syncStatus {
            case .unprepared, .error:
                do {
                    if syncStatus == .unprepared {
                        // swiftlint:disable:next force_try
                        _ = try! await aSynchronizer.prepare(
                            with: PirateAppConfig.defaultSeed,
                            viewingKeys: [appDelegate.sharedViewingKey],
                            walletBirthday: PirateAppConfig.defaultBirthdayHeight
                        )
                    }

                    aSynchronizer.metrics.enableMetrics()
                    try await aSynchronizer.start()
                    updateUI()
                } catch {
                    printLog("Can't start synchronizer: \(error)")
                    updateUI()
                }
            default:
                aSynchronizer.stop()
                aSynchronizer.metrics.disableMetrics()
                updateUI()
            }

            updateUI()
            
        }
        
      
    }
    
    func doStartStopNewWallet(with defaultSeed: [UInt8]?,
                              viewingKeys: [UnifiedFullViewingKey],
                              walletBirthday: BlockHeight) async {
        
        if let aSynchronizer = synchronizer  {
            let syncStatus = aSynchronizer.latestState.syncStatus
            switch syncStatus {
            case .unprepared, .error:
                do {
                    if syncStatus == .unprepared {
                        // swiftlint:disable:next force_try
                        _ = try! await aSynchronizer.prepare(
                            with: defaultSeed,
                            viewingKeys: viewingKeys,
                            walletBirthday: walletBirthday
                        )
                    }

                    aSynchronizer.metrics.enableMetrics()
                    try await aSynchronizer.start()
                    updateUI()
                } catch {
                    printLog("Can't start synchronizer: \(error)")
                    updateUI()
                }
            default:
                aSynchronizer.stop()
                aSynchronizer.metrics.disableMetrics()
                updateUI()
            }

            updateUI()
            
        }
        
      
    }
    
    func fail(error: Error) {
        printLog("\(error)")
        updateUI()
    }
    
    func updateUI() {
        
        if let aSynchronizer = synchronizer  {
            
            let syncStatus = aSynchronizer.latestState.syncStatus

            // STATUS
            printLog(textFor(state: syncStatus))

            // Button text
            printLog(buttonText(for: syncStatus))
        }
      
        
    }
    
    func buttonText(for state: SyncStatus) -> String {
        switch state {
        case .syncing:
            return "Pause"
        case .unprepared:
            return "Start"
        case .upToDate:
            return "Chill!"
        case .error:
            return "Retry"
        }
    }

    func textFor(state: SyncStatus) -> String {
        switch state {
        case .syncing:
            return "Syncing 🤖"
        case .upToDate:
            return "Up to Date 😎"
        case .unprepared:
            return "Unprepared"
        case .error(ZcashError.synchronizerDisconnected):
            return "Disconnected"
        case .error:
            return "error 💔"
        }
    }

    func wipe(_ sender: Any?) {
        
        appDelegate.wipe() { [weak self] possibleError in
            if let error = possibleError {
                printLog("WIPE FAILED")
                self?.wipeFailedAlert(error: error)
            } else {
                self?.wipeSuccessAlert()
                printLog("WIPE SUCCESS")
            }
        }
    }
    
    private func wipeFailedAlert(error: Error) {
        
        // show alert here for wipe failed
    }
    
    private func wipeSuccessAlert() {
        // Wipe success alert here
    }
}

struct ProcessorMetrics {
    var minHeight: BlockHeight
    var maxHeight: BlockHeight
    var maxDuration: (TimeInterval, CompactBlockRange)
    var minDuration: (TimeInterval, CompactBlockRange)
    var cumulativeDuration: TimeInterval
    var measuredCount: Int

    var averageDuration: TimeInterval {
        measuredCount > 0 ? cumulativeDuration / Double(measuredCount) : 0
    }

    static let initial = Self.init(
        minHeight: .max,
        maxHeight: .min,
        maxDuration: (TimeInterval.leastNonzeroMagnitude, 0 ... 1),
        minDuration: (TimeInterval.greatestFiniteMagnitude, 0 ... 1),
        cumulativeDuration: 0,
        measuredCount: 0
    )

    static func accumulate(_ prev: ProcessorMetrics, current: SDKMetrics.BlockMetricReport) -> Self {
        .init(
            minHeight: min(prev.minHeight, current.startHeight),
            maxHeight: max(prev.maxHeight, current.progressHeight),
            maxDuration: compareDuration(
                prev.maxDuration,
                (current.duration, current.progressHeight - current.batchSize ... current.progressHeight),
                max
            ),
            minDuration: compareDuration(
                prev.minDuration,
                (current.duration, current.progressHeight - current.batchSize ... current.progressHeight),
                min
            ),
            cumulativeDuration: prev.cumulativeDuration + current.duration,
            measuredCount: prev.measuredCount + 1
        )
    }

    static func compareDuration(
        _ prev: (TimeInterval, CompactBlockRange),
        _ current: (TimeInterval, CompactBlockRange),
        _ cmp: (TimeInterval, TimeInterval) -> TimeInterval
    ) -> (TimeInterval, CompactBlockRange) {
        cmp(prev.0, current.0) == current.0 ? current : prev
    }
}


extension ProcessorMetrics: CustomDebugStringConvertible {
    var debugDescription: String {
        """
        ProcessorMetrics:
            minHeight: \(self.minHeight)
            maxHeight: \(self.maxHeight)

            avg time: \(self.averageDuration)
            overall time: \(self.cumulativeDuration)
            slowest range:
                range:  \(self.maxDuration.1.description)
                count:  \(self.maxDuration.1.count)
                seconds: \(self.maxDuration.0)
            Fastest range:
                range: \(self.minDuration.1.description)
                count: \(self.minDuration.1.count)
                seconds: \(self.minDuration.0)
        """
    }
}


extension CompactBlockRange {
    var description: String {
        "\(self.lowerBound) ... \(self.upperBound)"
    }
}

extension SDKMetrics.BlockMetricReport: CustomDebugStringConvertible {
    public var debugDescription: String {
        """
        BlockMetric:
            startHeight: \(self.progressHeight - self.batchSize)
            endHeight: \(self.progressHeight)
            batchSize: \(self.batchSize)
            duration: \(self.duration)
        """
    }
}

