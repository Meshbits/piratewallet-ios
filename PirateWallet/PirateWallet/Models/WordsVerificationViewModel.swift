//
//  WordsVerificationViewModel.swift
//  PirateWallet
//
//  Created by Lokesh on 16/09/24.
//

import SwiftUI
import AlertToast
final class WordsVerificationViewModel: ObservableObject {
    
    @Published var firstWord = ""
    @Published var secondWord = ""
    @Published var thirdWord = ""
    @Published var firstWordIndex:Int = 0
    @Published var secondWordIndex:Int = 0
    @Published var thirdWordIndex:Int = 0
    @Published var mCompletePhrase:[String]?
    @Published var mWordsVerificationCompleted = false
  
    init(mPhrase:[String]) {
        mCompletePhrase = mPhrase
        
        assignElementsOnUI()
        
        debugPrint(mCompletePhrase)
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
