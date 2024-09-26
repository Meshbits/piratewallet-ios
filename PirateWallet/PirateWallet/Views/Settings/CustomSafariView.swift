//
//  CustomSafariView.swift
//  PirateWallet
//
//  Created by Lokesh on 26/09/24.
//

import SwiftUI
import SafariServices


struct CustomSafariView: UIViewControllerRepresentable {

    let url: URL

    func makeUIViewController(context: UIViewControllerRepresentableContext<CustomSafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<CustomSafariView>) {

    }

}
