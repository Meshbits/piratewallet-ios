//
//  TransactionsDataSource.swift
//  PirateWallet
//
//  Created by Lokesh on 04/10/24.
//

import Foundation
import UIKit
import PirateLightClientKit

class TransactionsDataSource: NSObject {
    enum TransactionType {
        case pending
        case sent
        case received
        case cleared
        case all
    }
    
    
    // swiftlint:disable:next implicitly_unwrapped_optional
    var synchronizer: Synchronizer!
    var transactions: [TransactionDetailModel] = []

    private var status: TransactionType

    init(status: TransactionType, synchronizer: Synchronizer) {
        self.status = status
        self.synchronizer = synchronizer      
    }

    // swiftlint:disable:next cyclomatic_complexity
    func load() async throws {
        transactions = []
        switch status {
        case .pending:
            printLog("PRINTING PENDING TRANSACTIONS")
            let rawTransactions = await synchronizer.pendingTransactions
            printLog("rawTransactions: \(rawTransactions.count)")
            for pendingTransaction in rawTransactions {
                let memos = try await synchronizer.getMemos(for: pendingTransaction)
                transactions.append(TransactionDetailModel(pendingTransaction: pendingTransaction, memos: memos))
            }

        case .cleared:
            let rawTransactions = await synchronizer.transactions
            printLog("rawTransactions cleared: \(rawTransactions.count)")

            for transaction in rawTransactions {
                let memos = try await synchronizer.getMemos(for: transaction)
                transactions.append(TransactionDetailModel(transaction: transaction, memos: memos))
            }
        case .received:
            let rawTransactions = await synchronizer.receivedTransactions
            printLog("rawTransactions received: \(rawTransactions.count)")

            for transaction in rawTransactions {
                let memos = try await synchronizer.getMemos(for: transaction)
                transactions.append(TransactionDetailModel(receivedTransaction: transaction, memos: memos))
            }
        case .sent:
            printLog("PRINTING SENT TRANSACTIONS")
            let rawTransactions = await synchronizer.sentTransactions
            printLog("rawTransactions sent: \(rawTransactions.count)")

            for transaction in rawTransactions {
                let memos = try await synchronizer.getMemos(for: transaction)
                transactions.append(TransactionDetailModel(sendTransaction: transaction, memos: memos))
            }
        case .all:
            let rawPendingTransactions = await synchronizer.pendingTransactions
            printLog("rawTransactions all: \(rawPendingTransactions.count)")

            for pendingTransaction in rawPendingTransactions {
                let memos = try await synchronizer.getMemos(for: pendingTransaction)
                transactions.append(TransactionDetailModel(pendingTransaction: pendingTransaction, memos: memos))
            }

            let rawClearedTransactions = await synchronizer.transactions
            for transaction in rawClearedTransactions {
                let memos = try await synchronizer.getMemos(for: transaction)
                transactions.append(TransactionDetailModel(transaction: transaction, memos: memos))
            }
        }
    }
}
