//
//  GenerateWordsViewModel.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//


import SwiftUI
import AlertToast

enum Words: Int {
    case word_one
    case word_two
    case word_three
    case word_four
    case word_five
    case word_six
    case word_seven
    case word_eight
    case word_nine
    case word_ten
    case word_eleven
    case word_twelve
    case word_thirteen
    case word_fourteen
    case word_fifteen
    case word_sixteen
    case word_seventeen
    case word_eighteen
    case word_nineteen
    case word_twenty
    case word_twenty_one
    case word_twenty_two
    case word_twenty_three
    case word_twenty_four
    case word_next
    
    
    var id: Int {
        switch self {
        case .word_one:
            return 1
        case .word_two:
            return 2
        case .word_three:
            return 3
        case .word_four:
            return 4
        case .word_five:
            return 5
        case .word_six:
            return 6
        case .word_seven:
            return 7
        case .word_eight:
            return 8
        case .word_nine:
            return 9
        case .word_ten:
            return 10
        case .word_eleven:
            return 11
        case .word_twelve:
            return 12
        case .word_thirteen:
            return 13
        case .word_fourteen:
            return 14
        case .word_fifteen:
            return 15
        case .word_sixteen:
            return 16
        case .word_seventeen:
            return 17
        case .word_eighteen:
            return 18
        case .word_nineteen:
            return 19
        case .word_twenty:
            return 20
        case .word_twenty_one:
            return 21
        case .word_twenty_two:
            return 22
        case .word_twenty_three:
            return 23
        case .word_twenty_four:
            return 24
        case .word_next:
            return 25
        }
    }
    
    mutating func next(){
        self = Words(rawValue: rawValue + 1) ?? Words(rawValue: 0)!
    }
    
    mutating func previous(){
        self = Words(rawValue: rawValue - 1) ?? Words(rawValue: 0)!
    }
}

final class GenerateAndVerifyWordsViewModel: ObservableObject {
    
    @Published var mWordTitle = ""
    
    @Published var mWordIndex = 1
    
    @Published var mVisibleWord: Words = Words.word_one
    
    var isRandomKeyPhraseAlreadyGenerated = false
    
    var randomKeyPhrase:[String]?
    
    @Published var mWordsVerificationScreen = false
        
    @Published var firstWord = ""
    
    @Published var secondWord = ""
    
    @Published var thirdWord = ""
    
    @Published var firstWordIndex:Int = 0
    
    @Published var secondWordIndex:Int = 0
    
    @Published var thirdWordIndex:Int = 0
    
    @Published var mCompletePhrase:[String]?
    
    @Published var mWordsVerificationCompleted = false
  
    
    init() {
        
        if !isRandomKeyPhraseAlreadyGenerated {
            
            do {
                randomKeyPhrase =  try MnemonicSeedProvider.default.randomMnemonicWords()
                
                mWordTitle = randomKeyPhrase![0]
                
                if let mCompletePhrase = randomKeyPhrase {
                    self.initializeWordsVerification(mPhrase: mCompletePhrase)
                }
                
            } catch {
                // Handle error in here
            }
            isRandomKeyPhraseAlreadyGenerated = true
        }
    }
    
    
    func backPressedToPopBack(){
        
        mVisibleWord.previous()
        
        mWordIndex = mVisibleWord.rawValue + 1
        
        mWordTitle = randomKeyPhrase![mVisibleWord.rawValue]
    }
    
    
    func updateLayoutTextOrMoveToNextScreen(){
        
        mVisibleWord.next()
        
        mWordIndex = mVisibleWord.rawValue + 1
        
        if mWordIndex > 24 {
            mWordsVerificationScreen = true
            backPressedToPopBack()
        }else{
            mWordTitle = randomKeyPhrase![mVisibleWord.rawValue]
        }
    }
    
    func initializeWordsVerification(mPhrase:[String]) {
        mCompletePhrase = mPhrase
        
        assignElementsOnUI()
        
        printLog(mCompletePhrase)
    }
    
    
    func assignElementsOnUI(){
        
        let indexes = getRandomWordsIndex()
        
        if (mCompletePhrase!.count > 0){
            firstWordIndex = indexes[0]
            secondWordIndex = indexes[1]
            thirdWordIndex = indexes[2]
        }
        
    }
    
    
    func validateAndMoveToNextScreen(){
        
        if (!firstWord.isEmpty && firstWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == mCompletePhrase![firstWordIndex].lowercased().trimmingCharacters(in: .whitespacesAndNewlines)){
            
            if (!secondWord.isEmpty && secondWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == mCompletePhrase![secondWordIndex].lowercased().trimmingCharacters(in: .whitespacesAndNewlines)){
                
                if (!thirdWord.isEmpty && thirdWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines) == mCompletePhrase![thirdWordIndex].lowercased().trimmingCharacters(in: .whitespacesAndNewlines)){
                    
                    mWordsVerificationCompleted = true
                    
                    print("MATCHED")
                    
                }else{
                    NotificationCenter.default.post(name: NSNotification.Name("UpdateErrorLayoutInvalidDetails"), object: nil)
                    print("NOT MATCHED AND NOTIFY USER")
                }
            }else{
                NotificationCenter.default.post(name: NSNotification.Name("UpdateErrorLayoutInvalidDetails"), object: nil)
                print("NOT MATCHED AND NOTIFY USER")
            }
            
        }else{
            NotificationCenter.default.post(name: NSNotification.Name("UpdateErrorLayoutInvalidDetails"), object: nil)
            print("NOT MATCHED AND NOTIFY USER")
        }
        
        
    }
    
    func getRandomWordsIndex()->[Int]{
          
          var allIndexes = Array(0...23)
        
          var uniqueNumbers = [Int]()
          
          while allIndexes.count > 0 {
              
              let number = Int(arc4random_uniform(UInt32(allIndexes.count)))
              
                uniqueNumbers.append(allIndexes[number])
              
                allIndexes.swapAt(number, allIndexes.count-1)
              
                allIndexes.removeLast()
            
                if uniqueNumbers.count == 3 {
                    break
                }
          }
          
          return uniqueNumbers
      }
}
