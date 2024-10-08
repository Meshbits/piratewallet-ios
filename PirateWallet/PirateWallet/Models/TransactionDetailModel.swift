//
//  TransactionDetailModel.swift
//  PirateWallet
//
//  Created by Lokesh on 04/10/24.
//

import UIKit
import PirateLightClientKit

final class TransactionDetailModel {
    enum Transaction {
        case sent(ZcashTransaction.Overview)
        case received(ZcashTransaction.Overview)
        case pending(ZcashTransaction.Overview)
        case cleared(ZcashTransaction.Overview)
    }

    let transaction: Transaction
    var id: Data?
    var minedHeight: BlockHeight?
    var expiryHeight: BlockHeight?
    var created: Date?
    var zatoshi: Zatoshi
    var memo: Memo?
    
    init(sendTransaction transaction: ZcashTransaction.Overview, memos: [Memo]) {
        self.transaction = .sent(transaction)
        self.id = transaction.rawID
        self.minedHeight = transaction.minedHeight
        self.expiryHeight = transaction.expiryHeight

        self.zatoshi = transaction.value
        self.memo = memos.first

        if let blockTime = transaction.blockTime {
            created = Date(timeIntervalSince1970: blockTime)
        } else {
            created = nil
        }
    }

    init(receivedTransaction transaction: ZcashTransaction.Overview, memos: [Memo]) {
        self.transaction = .received(transaction)
        self.id = transaction.rawID
        self.minedHeight = transaction.minedHeight
        self.expiryHeight = transaction.expiryHeight
        self.zatoshi = transaction.value
        self.memo = memos.first
        self.created = Date(timeIntervalSince1970: transaction.blockTime ?? Date().timeIntervalSince1970)
    }
    
    init(pendingTransaction transaction: ZcashTransaction.Overview, memos: [Memo]) {
        self.transaction = .pending(transaction)
        self.id = transaction.rawID
        self.minedHeight = transaction.minedHeight
        self.expiryHeight = transaction.expiryHeight
        self.created = Date(timeIntervalSince1970: transaction.blockTime ?? Date().timeIntervalSince1970)
        self.zatoshi = transaction.value
        self.memo = memos.first
    }
    
    init(transaction: ZcashTransaction.Overview, memos: [Memo]) {
        self.transaction = .cleared(transaction)
        self.id = transaction.rawID
        self.minedHeight = transaction.minedHeight
        self.expiryHeight = transaction.expiryHeight
        self.zatoshi = transaction.value
        self.memo = memos.first

        if let blockTime = transaction.blockTime {
            created = Date(timeIntervalSince1970: blockTime)
        } else {
            created = nil
        }
    }

    func loadMemos(from synchronizer: Synchronizer) async throws -> [Memo] {
        switch transaction {
        case let .sent(transaction):
            return try await synchronizer.getMemos(for: transaction)
        case let .received(transaction):
            return try await synchronizer.getMemos(for: transaction)
        case .pending:
            return []
        case let .cleared(transaction):
            return try await synchronizer.getMemos(for: transaction)
        }
    }

    func loadMemos(from synchronizer: Synchronizer, completion: @escaping (Result<[Memo], Error>) -> Void) {
        Task {
            do {
                let memos = try await loadMemos(from: synchronizer)
                DispatchQueue.main.async {
                    completion(.success(memos))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }
}
extension TransactionDetailModel {
    var dateDescription: String {
        self.created?.formatted(date: .abbreviated, time: .shortened) ?? "No date"
    }

    var amountDescription: String {
        self.zatoshi.amount.description
    }
}
