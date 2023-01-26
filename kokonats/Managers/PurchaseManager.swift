////  PurchaseManager.swift
//  kokonats
//
//  Created by sean on 2021/10/13.
//  
//

import Foundation
import StoreKit

protocol PurchaseManagerDelegate: AnyObject {
    func purchaseManagerDidPurchaseKoko(transaction: SKPaymentTransaction, completion: @escaping () -> Void)
    func purchaseManagerFailedPurchaseKoko(transaction: SKPaymentTransaction, reason: Int)
}

class PurchaseManager: NSObject {

    static let shared = PurchaseManager()

    var isAuthorizedForPayments: Bool {
        return SKPaymentQueue.canMakePayments()
    }

    var delegate: PurchaseManagerDelegate?
    var transactionState: SKPaymentTransactionState = .deferred
    private var lastPurchaseDate: Date?

    private override init() {}

    /// Create and add a payment request to the payment queue.
    // https://developer.apple.com/documentation/storekit/skpaymentqueue/1506123-restorecompletedtransactions
    // This method has no effect  such as a non-renewing subscription or a consumable product.
    func buy(_ product: SKProduct) {
        guard AppData.shared.isLoggedIn() else {
            NotificationCenter.default.post(name: .needLogin, object: nil)
            return
        }

        let payment = SKMutablePayment(product: product)
        SKPaymentQueue.default().add(payment)
        lastPurchaseDate = Date()
    }

    private func handlePurchased(_ transaction: SKPaymentTransaction) {
        verifyReceipt(transaction: transaction, retry: 40) { verified in
            if verified {
                Logger.debug("\(transaction.transactionIdentifier) finishTransaction")
                SKPaymentQueue.default().finishTransaction(transaction)
                self.transactionState = .purchased
                DispatchQueue.main.async { [weak self] in
                    self?.delegate?.purchaseManagerDidPurchaseKoko(transaction: transaction) {}
                }
            } else {
                DispatchQueue.main.async {
                    self.delegate?.purchaseManagerFailedPurchaseKoko(transaction: transaction, reason: 2)
                }
//                DispatchQueue.main.async { [weak self] in
//                    self?.delegate?.purchaseManagerDidPurchaseKoko(transaction: transaction) { verified in
//                        if verified {
//                            Logger.debug(transaction.transactionIdentifier ?? "")
//                            SKPaymentQueue.default().finishTransaction(transaction)
//                            self?.transactionState = .purchased
//                        }
//                    }
//                }
            }
        }
    }

    private func handleFailed(_ transaction: SKPaymentTransaction) {
        if let error = transaction.error {
            Logger.debug(" \(error.localizedDescription)")
        }

        // Do not send any notifications when the user cancels the purchase.
        if (transaction.error as? SKError)?.code != .paymentCancelled {
            DispatchQueue.main.async {
                self.delegate?.purchaseManagerFailedPurchaseKoko(transaction: transaction, reason: 1)
            }
        }
        // Finish the failed transaction.
        SKPaymentQueue.default().finishTransaction(transaction)
        transactionState = .failed
    }

    private func verifyReceipt(transaction: SKPaymentTransaction, retry: Int, completion: @escaping (Bool) -> Void) {
        if let receipt = getReceipt(),
           let transactionId = transaction.transactionIdentifier,
           retry > 0 {
            Logger.debug("start verifying")
            DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
                ApiManager.shared.verifyReceipt(idToken: LocalStorageManager.idToken,
                                                transactionId: transactionId,
                                                receipt: receipt) { [weak self] result in
                    if case .success(let verification) = result {
                        Logger.debug("\(String(describing: transaction.transactionIdentifier)) result: \(verification.state), retry: \(40 - retry)")
                        if verification.state == 2 {
                            completion(true)
                            return
                        }
                    }
                    Logger.debug("\(String(describing: transaction.transactionIdentifier)) retry: \(retry)")
                    self?.verifyReceipt(transaction: transaction, retry: retry - 1, completion: completion)
                }
            }
        } else {
            completion(false)
            return
        }
    }

    private func getReceipt() -> String? {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.default.fileExists(atPath: appStoreReceiptURL.path) {

            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
//                Logger.debug(receiptString)
                return receiptString
            }
            catch {
                Logger.debug("Couldn't read receipt data with error: " + error.localizedDescription)
                return nil
            }
        }
        return nil
    }
}

extension PurchaseManager: SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing:
                transactionState = .purchasing

            //A transaction that is in the queue, but its final status is pending external action such as Ask to Buy.
            case .deferred:
                transactionState = .deferred

            case .purchased:
                handlePurchased(transaction)

            case .failed:
                handleFailed(transaction)

            case .restored:
                break

            @unknown default: fatalError("unknownPaymentTransaction")
            }
        }
    }
}
