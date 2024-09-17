//
//  String+localized.swift
//  PirateWallet
//
//  Created by Lokesh on 15/09/24.
//


import Foundation

extension String {
  
    func localized() -> String {
          return NSLocalizedString(self, tableName: nil, bundle: Bundle.localizedBundle(), value: "", comment: "")
    }

    func localizeWithFormat(arguments: CVarArg...) -> String{
          return String(format: self.localized(), arguments: arguments)
    }
}
