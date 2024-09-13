//
//  UIKit+Extensions.swift
//  PirateWallet
//
//  Created by Lokesh on 13/09/24.
//


import Foundation
import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

func PirateNavigationBarUI() {
    let appearance = UINavigationBarAppearance()
    appearance.configureWithTransparentBackground()
    appearance.largeTitleTextAttributes = [
        .font : UIFont.systemFont(ofSize: 12),
        NSAttributedString.Key.foregroundColor : UIColor.white
    ]
    
    appearance.titleTextAttributes = [
        .font : UIFont.systemFont(ofSize: 12),
        NSAttributedString.Key.foregroundColor : UIColor.white
    ]
    
    UINavigationBar.appearance().scrollEdgeAppearance = appearance
    UINavigationBar.appearance().standardAppearance = appearance
    UINavigationBar.appearance().tintColor = .white
    
    let clearView = UIView()
    clearView.backgroundColor = UIColor.clear
    UITableViewCell.appearance().selectedBackgroundView = clearView
    UITableView.appearance().backgroundColor = UIColor.clear
}
