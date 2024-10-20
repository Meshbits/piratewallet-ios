//
//  SceneDelegate.swift
//  PirateWallet
//
//  Created by Lokesh on 13/09/24.
//


import UIKit
import SwiftUI
import BackgroundTasks
import AVFoundation

let mPlaySoundWhileSyncing = "PlaySoundWhenAppEntersBackground"

let mStopSoundOnceFinishedOrInForeground = "StopSoundWhenAppEntersForeground"

let mUpdateVolume = "UpdateVolume"

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    var mBlurrViewTag = 1001
    
    var originalDelegate: UISceneDelegate?
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        
        // This is the use case of handling the URL Contexts - Deep linking when app is running in the background
        
//        logger.info("Opened up a deep link - App running in the background")
        
        if let url = URLContexts.first?.url {
            let urlDataDict:[String: URL] = ["url": url]

            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
//                logger.info("Opened up a deep link - App is not running in the background")
//                NotificationCenter.default.post(name: .openTransactionScreen, object: nil, userInfo: urlDataDict)
            }
        }
    }
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
//        Preventing screen from auto locking due to idle timer (usually happens while syncing/downloading)
        UIApplication.shared.isIdleTimerDisabled = true
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("MoveToFirstViewLayout"), object: nil, queue: .main) { (_) in
            self.addSwiftLayout(scene: scene)
        }
        
        /*
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(mPlaySoundWhileSyncing), object: nil, queue: .main) { (_) in
            self.playInitialSound()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(mStopSoundOnceFinishedOrInForeground), object: nil, queue: .main) { (_) in
            self.stopSoundIfPlaying()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(mUpdateVolume), object: nil, queue: .main) { (_) in
            self.updateSoundIfPlaying()
        }
        
        */
        
        if let url = connectionOptions.urlContexts.first?.url {
            let urlDataDict:[String: URL] = ["url": url]
            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
//                logger.info("Opened up a deep link - App is not running in the background")
//                NotificationCenter.default.post(name: .openTransactionScreen, object: nil, userInfo: urlDataDict)
            }
             
        }
        
        originalDelegate?.scene!(scene, willConnectTo: session, options: connectionOptions)

        
        self.addSwiftLayout(scene: scene)
    }
    
    func addSwiftLayout(scene: UIScene){
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            window.rootViewController = HostingController(rootView:
                    AnyView(
                        NavigationView {
//                            TheNoScreen(appEnvironment: ZECCWalletEnvironment.shared)
//                                .navigationBarHidden(true)
//                                .navigationBarBackButtonHidden(true)
                            TheNoScreen()
                        }
                    )
            )
            self.window = window
            self.window?.backgroundColor = .black
            self.window?.tintColor = .black
            PirateNavigationBarUI()
            window.makeKeyAndVisible()
            
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
//      Preventing screen from auto locking due to idle timer (usually happens while syncing/downloading)
        UIApplication.shared.isIdleTimerDisabled = true
        NotificationCenter.default.post(name: NSNotification.Name(mStopSoundOnceFinishedOrInForeground), object: nil)
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        self.window?.viewWithTag(mBlurrViewTag)?.removeFromSuperview()

    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        
        if let windowObj = window {
            blurEffectView.frame = windowObj.frame
            blurEffectView.tag = mBlurrViewTag
            self.window?.addSubview(blurEffectView)
        }
        
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
//        #if !targetEnvironment(simulator)
        //FIXME: disable background tasks for the time being
//        BackgroundTaskSyncronizing.default.scheduleBackgroundProcessing()
//        #endif
    }
    
    
    /*
    var mAVAudioPlayerObj : AVAudioPlayer?

    func playSoundWhileSyncing() {
        // Play sound only in background while syncing
//        if (UIApplication.shared.applicationState == .background){
        if !UserSettings.shared.isEnableSoundSettings {
            return
        }

            if let player = mAVAudioPlayerObj,player.isPlaying{
                    return
            }
            
            var aFileName = "BackgroundLongMusic_1"
            
            switch(UserSettings.shared.mBackgroundSoundSelectionIndex){
                case 0:
                    aFileName = "BackgroundLongMusic_1"
                    break
                case 1:
                    aFileName = "BackgroundLongMusic_2"
                    break
                case 2:
                    aFileName = "BackgroundLongMusic_3"
                break
                default:
                    print("None")
            }
            
            
            if let path = Bundle.main.path(forResource: aFileName, ofType: "aac") {
                let filePath = NSURL(fileURLWithPath:path)
                mAVAudioPlayerObj = try! AVAudioPlayer.init(contentsOf: filePath as URL)
                mAVAudioPlayerObj?.numberOfLoops = -1 //logic for infinite loop just to make sure it keeps running
                mAVAudioPlayerObj?.prepareToPlay()
                mAVAudioPlayerObj?.volume = UserSettings.shared.isBackgroundSoundEnabled ? (UserSettings.shared.mBackgroundSoundVolume ?? 0.05) : 0.001
                mAVAudioPlayerObj?.play()
            }
            
            //Causes audio from other sessions to be ducked (reduced in volume) while audio from this session plays
            let audioSession = AVAudioSession.sharedInstance()
            try!audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
//        }
    }
    
    func playInitialSound(){
        if !UserSettings.shared.isEnableSoundSettings {
            return
        }

//        if (UIApplication.shared.applicationState == .background){
            if UIApplication.shared.applicationState == .background {
                if let path = Bundle.main.path(forResource: "SyncStarted", ofType: "mp3") {
                    let filePath = NSURL(fileURLWithPath:path)
                    mAVAudioPlayerObj = try! AVAudioPlayer.init(contentsOf: filePath as URL)
                    mAVAudioPlayerObj?.prepareToPlay()
                    mAVAudioPlayerObj?.volume = UserSettings.shared.isBackgroundSoundEnabled ? (UserSettings.shared.mBackgroundSoundVolume ?? 0.05) : 0.0
                    mAVAudioPlayerObj?.play()
                }
            }
            
        
            if UIApplication.shared.applicationState != .background {
                self.playSoundWhileSyncing()
            }else{
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
                    self.mAVAudioPlayerObj?.stop()
                    self.playSoundWhileSyncing()
                }
            }
                        
            showNotificationInNotificationTrayWhileSyncing()
            
            //Causes audio from other sessions to be ducked (reduced in volume) while audio from this session plays
            let audioSession = AVAudioSession.sharedInstance()
            try!audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
//        }
    }
    
    func playFinishingSound(){
        if !UserSettings.shared.isEnableSoundSettings {
            return
        }

        if (UIApplication.shared.applicationState == .background){
            if let path = Bundle.main.path(forResource: "SyncEnd", ofType: "mp3") {
                let filePath = NSURL(fileURLWithPath:path)
                mAVAudioPlayerObj = try! AVAudioPlayer.init(contentsOf: filePath as URL)
                mAVAudioPlayerObj?.prepareToPlay()
                mAVAudioPlayerObj?.volume = UserSettings.shared.isBackgroundSoundEnabled ? (UserSettings.shared.mBackgroundSoundVolume ?? 0.05) : 0.0
                mAVAudioPlayerObj?.play()
            }
            
            //Causes audio from other sessions to be ducked (reduced in volume) while audio from this session plays
            let audioSession = AVAudioSession.sharedInstance()
            try!audioSession.setCategory(AVAudioSession.Category.playback, options: AVAudioSession.CategoryOptions.duckOthers)
        }else{
            if let player = mAVAudioPlayerObj,  player.isPlaying {
                player.stop()
            }
        }
    }
    
    func stopSoundIfPlaying(){
        
        if !UserSettings.shared.isEnableSoundSettings {
            return
        }
        
        // If AVAudio player is playing a song then go ahead and kill it
        if mAVAudioPlayerObj != nil && mAVAudioPlayerObj?.isPlaying == true {
            mAVAudioPlayerObj?.stop()
            playFinishingSound()
            removeNotificationInNotificationTrayWhileSyncingIsFinished()
        }
        
    }
    
    func updateSoundIfPlaying(){
        if !UserSettings.shared.isEnableSoundSettings {
            return
        }

        if let player = mAVAudioPlayerObj, player.isPlaying {
            mAVAudioPlayerObj?.volume = UserSettings.shared.isBackgroundSoundEnabled ? (UserSettings.shared.mBackgroundSoundVolume ?? 0.05) : 0.0
        }
    }
    
    static var shared: SceneDelegate {
        UIApplication.shared.windows[0].windowScene?.delegate as! SceneDelegate
    }
    
    func removeNotificationInNotificationTrayWhileSyncingIsFinished(){
        DispatchQueue.main.async {
            let content = UNUserNotificationCenter.current()
            content.removeAllDeliveredNotifications()
            content.removeAllPendingNotificationRequests()
        }
    }
    
    func showNotificationInNotificationTrayWhileSyncing(){
        DispatchQueue.main.async {
            let content = UNMutableNotificationContent()
            content.title = NSString.localizedUserNotificationString(forKey: "Pirate Chain Wallet", arguments: nil)
            content.body = NSString.localizedUserNotificationString(forKey: "Please keep the app running in the background, while we sync your wallet and keep it up to date. Thank you!",
                                                                    arguments: nil)
            content.sound = UNNotificationSound.default
            
            let date = Date(timeIntervalSinceNow: 3) // Post notification after 3 seconds
            let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

            // Create the request object.
            let request = UNNotificationRequest(identifier: "BackgroundSyncing", content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
              center.add(request) { (error) in
           }
        }
    }
     
     */
  
}

