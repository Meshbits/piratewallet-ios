//
//  AppDelegate.swift
//  PirateWallet
//
//  Created by Lokesh on 13/09/24.
//


import UIKit
import BackgroundTasks
import AVFoundation
import UserNotifications
import PirateLightClientKit
import NotificationBubbles
import Combine
import SwiftUI
import MnemonicSwift
import SecureDefaults

class AppDelegate: UIResponder, UIApplicationDelegate,ObservableObject {
//
//    let logger = PirateLogger(logLevel: .debug)

    static var isTouchIDVisible = false
    
    var cancellables: [AnyCancellable] = []
    var window: UIWindow?
    private var wallet: Initializer?
    private var synchronizer: SDKSynchronizer?
    
    var sharedSynchronizer: SDKSynchronizer {
        if let sync = synchronizer {
            return sync
        } else {
            let sync = SDKSynchronizer(initializer: sharedWallet) // this must break if fails
            self.synchronizer = sync
            return sync
        }
    }

    var sharedViewingKey: UnifiedFullViewingKey {
        let derivationTool = DerivationTool(networkType: kPirateNetwork.networkType)
        let spendingKey = try! derivationTool
            .deriveUnifiedSpendingKey(seed: PirateAppConfig.defaultSeed, accountIndex: 0)

        return try! derivationTool.deriveUnifiedFullViewingKey(from: spendingKey)
    }

    
    var sharedWallet: Initializer {
        if let wallet {
            return wallet
        } else {
            let wallet = Initializer(
                cacheDbURL: nil,
                fsBlockDbRoot: try! fsBlockDbRootURLHelper(),
                dataDbURL: try! dataDbURLHelper(),
                endpoint: PirateAppConfig.endpoint,
                network: kPirateNetwork,
                spendParamsURL: try! spendParamsURLHelper(),
                outputParamsURL: try! outputParamsURLHelper(),
                saplingParamsSourceURL: SaplingParamsSourceURL.default
            )

            self.wallet = wallet
            return wallet
        }
    }
    
    func subscribeToMinedTxNotifications() {
        sharedSynchronizer.eventStream
            .map { event in
                guard case let .minedTransaction(transaction) = event else { return nil }
                return transaction
            }
            .compactMap { $0 }
            .receive(on: DispatchQueue.main)
            .sink(
                receiveValue: { [weak self] transaction in self?.txMined(transaction) }
            )
            .store(in: &cancellables)
    }

    
    func txMined(_ transaction: ZcashTransaction.Overview) {
        NotificationBubble.display(
            in: window!.rootViewController!.view,
            options: NotificationBubble.sucessOptions(
                animation: NotificationBubble.Animation.fade(duration: 1)
            ),
            attributedText: NSAttributedString(string: "Transaction \(String(describing: transaction.id))mined!"),
            handleTap: {}
        )
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if connectingSceneSession.role == UISceneSession.Role.windowApplication {
            let config = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
            config.delegateClass = SceneDelegate.self
            return config
        }
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
       
        /*
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundTaskSyncronizing.backgroundProcessingTaskIdentifier,
          using: nil) { (task) in
            BackgroundTaskSyncronizing.default.handleBackgroundProcessingTask(task as! BGProcessingTask)
        }
        
        BGTaskScheduler.shared.register(
            forTaskWithIdentifier: BackgroundTaskSyncronizing.backgroundProcessingTaskIdentifierARRR,
          using: nil) { (task) in
            
        }
        */
        
        let secureDefaults = SecureDefaults()
        
        UNUserNotificationCenter.current().requestAuthorization(options:[.alert, .sound]) { (granted, error) in

              if granted {
                DispatchQueue.main.async {
                  UIApplication.shared.registerForRemoteNotifications()
                }
              }

        }
        
        printLog("STATUS ON LAUNCH")
        
        if SeedManager().keysPresent {
            if UserSettings.shared.currentSyncStatus == LocalSyncStatus.inProgress.rawValue {
                
                printLog("Yes, found something in progress, let's move to home screen instead of Login")
                
                PirateAppConfig.defaultBirthdayHeight = UserSettings.shared.lastSyncedBlockHeight     //sharedSynchronizer.initializer.walletBirthday
                
                PirateAppSynchronizer.shared.startStop()
            }else{
                printLog("No, Nothing found in progress")
            }
        }else{
            printLog("No user is logged into the app")
        }

        
        // To support background playing of audio
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.ambient)
        try? AVAudioSession.sharedInstance().setActive(true)

//        syncRange:                   2025846...3098444
//        downloadToHeight:            2049918
//        latestDownloadedBlockHeight: 2043909
//        range:                       2043910...2049918
        // Preventing screen from auto locking due to idle timer (usually happens while syncing/downloading)
        application.isIdleTimerDisabled = true
        
        // Ensures that a password was not set before. Otherwise, if
        // you set a password one more time, it will re-generate a key.
        // That means that we lose old data as well.
        if !secureDefaults.isKeyCreated {
            if let aPasscode = UserSettings.shared.aPasscode, !aPasscode.isEmpty {
                print("No need to update it here")
            }else{
                print("update it here please")
                secureDefaults.password = UUID().uuidString
                secureDefaults.synchronize()
                secureDefaults.set("We're using SecureDefaults!", forKey: "secure.greeting")
            }
        }
         
        
//        defaultsForBackgroundSoundSettings()
        return true
    }
    
//    func defaultsForBackgroundSoundSettings(){
//        let userDefaults = UserDefaults.standard
//
//        if userDefaults.bool(forKey: "didWeInstallItAlready") == false {
//
//               // updating the local flag
//               userDefaults.set(true, forKey: "didWeInstallItAlready")
//               userDefaults.synchronize() // forces the app to update the NSUserDefaults
//
//               UserSettings.shared.isBackgroundSoundEnabled = true
//               UserSettings.shared.mBackgroundSoundVolume = 0.05
//               return
//       }
//    }
//    
    /*
     Not required anymore
    func clearKeyChainIfAnythingExists(){
        let userDefaults = UserDefaults.standard

        if userDefaults.bool(forKey: "didWeInstallItBefore") == false {

               // removing all keychain items in here
                SeedManager.default.nukeWallet()
               // updating the local flag
               userDefaults.set(true, forKey: "didWeInstallItBefore")
               userDefaults.synchronize() // forces the app to update the NSUserDefaults

               return
           }
    }
    */
    
    // MARK: UISceneSession Lifecycle
    
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
    
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
  
}


extension AppDelegate {

    static var shared: AppDelegate {
        UIApplication.shared.delegate as! AppDelegate
    }

    func wipe(completion completionClosure: @escaping (Error?) -> Void) {
        guard let synchronizer = (UIApplication.shared.delegate as? AppDelegate)?.sharedSynchronizer else { return }

        // At this point app should show some loader or some UI that indicates action. If the sync is not running then wipe happens immediately.
        // But if the sync is in progress then the SDK must first stop it. And it may take some time.

        synchronizer.wipe()
            // Delay is here to be sure that previously showed alerts are gone and it's safe to show another. Or I want to show loading UI for at
            // least one second in case that wipe happens immediately.
            .delay(for: .seconds(1), scheduler: DispatchQueue.main, options: .none)
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        completionClosure(nil)
                    case .failure(let error):
                        completionClosure(error)
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }
}

extension Initializer {
    static var shared: Initializer {
        AppDelegate.shared.sharedWallet // AppDelegate or DIE.
    }
}

extension Synchronizer {
    static var shared: Synchronizer {
        AppDelegate.shared.sharedSynchronizer
    }
}

func documentsDirectoryHelper() throws -> URL {
    try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
}

func fsBlockDbRootURLHelper() throws -> URL {
    try documentsDirectoryHelper()
        .appendingPathComponent(kPirateNetwork.networkType.chainName)
        .appendingPathComponent(
            PirateSDK.defaultFsCacheName,
            isDirectory: true
        )
}

func cacheDbURLHelper() throws -> URL {
    try documentsDirectoryHelper()
        .appendingPathComponent(
            kPirateNetwork.constants.defaultDbNamePrefix + PirateSDK.defaultCacheDbName,
            isDirectory: false
        )
}

func dataDbURLHelper() throws -> URL {
    try documentsDirectoryHelper()
        .appendingPathComponent(
            kPirateNetwork.constants.defaultDbNamePrefix + PirateSDK.defaultDataDbName,
            isDirectory: false
        )
}

func spendParamsURLHelper() throws -> URL {
    try documentsDirectoryHelper().appendingPathComponent("sapling-spend.params")
}

func outputParamsURLHelper() throws -> URL {
    try documentsDirectoryHelper().appendingPathComponent("sapling-output.params")
}

public extension NotificationBubble {
    static func sucessOptions(animation: NotificationBubble.Animation) -> [NotificationBubble.Style] {
        return [
            NotificationBubble.Style.animation(animation),
            NotificationBubble.Style.margins(UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)),
            NotificationBubble.Style.cornerRadius(8),
            NotificationBubble.Style.duration(timeInterval: 10),
            NotificationBubble.Style.backgroundColor(UIColor.green)
        ]
    }
}
