//
//  DetailModel.swift
//  PirateWallet
//
//  Created by Lokesh on 23/09/24.
//

import SwiftUI

struct DetailModel: Identifiable {
    
    enum Status {
        case paid(success: Bool)
        case received
    }
    var id: String
    var arrrAddress: String?
    var date: Date
    var arrrAmount: Double
    var status: Status
    var shielded: Bool = true
    var memo: String? = nil
    var minedHeight: Int = -1
    var expirationHeight: Int = -1
    var title: String {

        switch status {
        case .paid(let success):
            return success ? "You paid \(arrrAddress?.shortARRRaddress ?? "Unknown".localized())" : "Unsent Transaction".localized()
        case .received:
            return "\(arrrAddress?.shortARRRaddress ?? "Unknown") paid you".localized()
        }
    }
    
    var subtitle: String
    
}

extension DetailModel: Equatable {
    static func == (lhs: DetailModel, rhs: DetailModel) -> Bool {
        lhs.id == rhs.id
    }
}
