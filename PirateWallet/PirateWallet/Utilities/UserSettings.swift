//
//  UserSettings.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import Foundation

class UserSettings {
    
    static let shared = UserSettings()
    
    private init() {}
    struct Keys {
        static let lastUsedAddress = "lastUsedAddress"
        static let everShielded = "everShielded"
        static let rescanPendingFix = "rescanPendingFix"
        static let lastFeedbackDisplayedOnDate = "lastFeedbackDisplayedOnDate"
        static let aPasscode = "aPasscode"
        static let aBiometricInAppStatus = "aBiometricInAppStatus"
        static let aBiometricEnabled = "aBiometricEnabled"
        static let aLanguageSelectionIndex = "aLanguageSelectionIndex"
        static let isAutoConfigurationOn = "isAutoConfigurationOn"
        static let lastUpdatedTime = "lastSavedTime"
        static let didShowAutoShieldingNotice = "didShowAutoShieldingNotice"
        static let listOfSelectedCurrencies = "listOfSelectedCurrencies"
        static let indexOfSelectedExchange = "listOfSelectedExchange"
        static let mBackgroundSoundVolume = "mBackgroundSoundVolume"
        static let mBackgroundSoundSelectionIndex = "mBackgroundSoundSelectionIndex"
        static let isBackgroundSoundEnabled = "isBackgroundSoundEnabled"
        static let isSyncCompleted = "isSyncCompleted"
        static let lastSyncedBlockHeight = "lastSyncedBlockHeight"
    }
    
    var isEnableSoundSettings = true // We also need to turn on audio settings under background modes
 
    var indexOfSelectedExchange: Int? {
        get {
            UserDefaults.standard.integer(forKey: Keys.indexOfSelectedExchange)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.indexOfSelectedExchange)
        }
    }
    
    var listOfSelectedCurrencies: [String]? {
        get {
            UserDefaults.standard.stringArray(forKey: Keys.listOfSelectedCurrencies)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.listOfSelectedCurrencies)
        }
    }
        
    var mBackgroundSoundVolume: Float? {
        get {
            UserDefaults.standard.float(forKey: Keys.mBackgroundSoundVolume)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.mBackgroundSoundVolume)
        }
    }
    
    var mBackgroundSoundSelectionIndex: Int? {
        get {
            UserDefaults.standard.integer(forKey: Keys.mBackgroundSoundSelectionIndex)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.mBackgroundSoundSelectionIndex)
        }
    }
    
    var lastUpdatedTime: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.lastUpdatedTime)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.lastUpdatedTime)
        }
    }
        
    var aPasscode: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.aPasscode)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.aPasscode)
        }
    }
    
    var didShowAutoShieldingNotice: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.didShowAutoShieldingNotice)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.didShowAutoShieldingNotice)
        }
    }
    
    var isBackgroundSoundEnabled: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.isBackgroundSoundEnabled)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isBackgroundSoundEnabled)
        }
    }
    
    var lastUsedAddress: String? {
        get {
            UserDefaults.standard.string(forKey: Keys.lastUsedAddress)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.lastUsedAddress)
        }
    }
    
    var userEverShielded: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.everShielded)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.everShielded)
        }
    }
    
    var didRescanPendingFix: Bool {
        get {
            UserDefaults.standard.bool(forKey: Keys.rescanPendingFix)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey:Keys.rescanPendingFix)
        }
    }
    
    var lastFeedbackDisplayedOnDate: Date? {
        get {
            guard let timeInterval = UserDefaults.standard.value(forKey: Keys.lastFeedbackDisplayedOnDate) as? TimeInterval else {
                return nil
            }
            
            return Date(timeIntervalSinceReferenceDate: timeInterval)
        }
        set {
            UserDefaults.standard.setValue(newValue?.timeIntervalSinceReferenceDate, forKey: Keys.lastFeedbackDisplayedOnDate)
        }
    }
    
    var biometricInAppStatus: Bool  {
         get {
             UserDefaults.standard.bool(forKey: Keys.aBiometricInAppStatus)
         }
         set {
             UserDefaults.standard.setValue(newValue, forKey: Keys.aBiometricInAppStatus)
         }
     }
     
     var isBiometricDisabled: Bool  {
         get {
             UserDefaults.standard.bool(forKey: Keys.aBiometricEnabled)
         }
         set {
             UserDefaults.standard.setValue(newValue, forKey: Keys.aBiometricEnabled)
         }
     }
    
    var languageSelectionIndex: Int  {
        get {
            UserDefaults.standard.integer(forKey: Keys.aLanguageSelectionIndex)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.aLanguageSelectionIndex)
        }
    }
    
    
    var isAutoConfigurationOn: Bool  {
        get {
            UserDefaults.standard.bool(forKey: Keys.isAutoConfigurationOn)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isAutoConfigurationOn)
        }
    }

    var isSyncCompleted: Bool  {
        get {
            UserDefaults.standard.bool(forKey: Keys.isSyncCompleted)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.isSyncCompleted)
        }
    }
    
    
    var lastSyncedBlockHeight: Int  {
        get {
            UserDefaults.standard.integer(forKey: Keys.lastSyncedBlockHeight)
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: Keys.lastSyncedBlockHeight)
        }
    }
    
    func removeAllSettings() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
}
