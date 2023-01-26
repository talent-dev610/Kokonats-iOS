////  StoreManager.swift
//  kokonats
//
//  Created by sean on 2021/10/12.
//  
//

import StoreKit
import Foundation


enum KokoProductType: CaseIterable {
    case energy85
    case energy180
    case energy430
    case energy855
    case energy1720
    case energy4300

    var identifier: String {
        switch self {
        case .energy85:
            return "club.kokonats.koko.ios.energy.85"
        case .energy180:
            return "club.kokonats.koko.ios.energy.180"
        case .energy430:
            return "club.kokonats.koko.ios.energy.430"
        case .energy855:
            return "club.kokonats.koko.ios.energy.855"
        case .energy1720:
            return "club.kokonats.koko.ios.energy.1720"
        case .energy4300:
            return "club.kokonats.koko.ios.energy.4300"
        }
    }

    var price: Int {
        switch self {
        case .energy85:
            return 120
        case .energy180:
            return 250
        case .energy430:
            return 610
        case .energy855:
            return 1220
        case .energy1720:
            return 2440
        case .energy4300:
            return 6100
        }
    }

    var energy: Int {
        switch self {
        case .energy85:
            return 85
        case .energy180:
            return 180
        case .energy430:
            return 430
        case .energy855:
            return 855
        case .energy1720:
            return 1720
        case .energy4300:
            return 4300
        }
    }


}

enum SectionType: String, CustomStringConvertible {
    case availableProducts = "AVAILABLE PRODUCTS"
    case invalidProductIdentifiers = "INVALID PRODUCT IDENTIFIERS"
    case purchased = "PURCHASED"
    case restored = "RESTORED"
    var description: String {
        return self.rawValue
    }
}

/// A structure that is used to represent a list of products or purchases.
struct Section {
    /// Products/Purchases are organized by category.
    var type: SectionType
    /// List of products/purchases.
    var elements = [Any]()
}

class StoreManager: NSObject {
    static let shared = StoreManager()
    static let energyProductList: [KokoProductType] = [
        .energy85,
        .energy180,
        .energy430,
        .energy855,
        .energy1720,
        .energy4300
    ]

    // MARK: - Properties

    /// Keeps track of all valid products. These products are available for sale in the App Store.
    fileprivate var availableProducts = [SKProduct]()

    /// Keeps track of all invalid product identifiers.
    fileprivate var invalidProductIdentifiers = [String]()

    /// Keeps a strong reference to the product request.
    fileprivate var productRequest: SKProductsRequest!
    /// Keeps track of all valid products (these products are available for sale in the App Store) and of all invalid product identifiers.

    /// Keeps track of all valid products (these products are available for sale in the App Store) and of all invalid product identifiers.
    fileprivate var validProducts = [Section]()

//    weak var delegate: StoreManagerDelegate?

    // MARK: - Initializer

    private override init() {}

    // MARK: - Request Product Information

    /// Starts the product request with the specified identifiers.
    // club.kokonats.koko.ios.energy.100
    func fetchProductsIfNeeded() {
        var identifiers = [String]()
        KokoProductType.allCases.forEach {
            identifiers.append($0.identifier)
        }

        guard !identifiers.isEmpty else {
            return
        }

        fetchProducts(matchingIdentifiers: identifiers)
    }

    /// Fetches information about your products from the App Store.
    private func fetchProducts(matchingIdentifiers identifiers: [String]) {
        // Create a set for the product identifiers.
        let productIdentifiers = Set(identifiers)

        // Initialize the product request with the above identifiers.
        productRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productRequest.delegate = self

        // Send the request to the App Store.
        productRequest.start()
    }

    // MARK: - Helper Methods

    /// - returns: Existing product's title matching the specified product identifier.
    func title(matchingIdentifier identifier: String) -> String? {
        var title: String?
        guard !availableProducts.isEmpty else { return nil }

        // Search availableProducts for a product whose productIdentifier property matches identifier. Return its localized title when found.
        let result = availableProducts.filter({ (product: SKProduct) in product.productIdentifier == identifier })

        if !result.isEmpty {
            title = result.first!.localizedTitle
        }
        return title
    }

    /// - returns: Existing product's title associated with the specified payment transaction.
    func title(matchingPaymentTransaction transaction: SKPaymentTransaction) -> String {
        let title = self.title(matchingIdentifier: transaction.payment.productIdentifier)
        return title ?? transaction.payment.productIdentifier
    }

    func product(identifier: String) -> SKProduct? {
        return availableProducts.first(where: { $0.productIdentifier == identifier })
    }
}

// MARK: - SKProductsRequestDelegate

/// Extends StoreManager to conform to SKProductsRequestDelegate.
extension StoreManager: SKProductsRequestDelegate {
    /// Used to get the App Store's response to your request and notify your observer.
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {

        validProducts.removeAll()

        // products contains products whose identifiers have been recognized by the App Store. As such, they can be purchased.
        if !response.products.isEmpty {
            availableProducts = response.products
        }

        // invalidProductIdentifiers contains all product identifiers not recognized by the App Store.
        if !response.invalidProductIdentifiers.isEmpty {
            invalidProductIdentifiers = response.invalidProductIdentifiers
        }

        if !availableProducts.isEmpty {
            validProducts.append(Section(type: .availableProducts, elements: availableProducts))
        }

        if !invalidProductIdentifiers.isEmpty {
            validProducts.append(Section(type: .invalidProductIdentifiers, elements: invalidProductIdentifiers))
        }

        if !validProducts.isEmpty {
            DispatchQueue.main.async {
//                self.delegate?.storeManagerDidReceiveResponse(self.storeResponse)
            }
        }
    }
}

// MARK: - SKRequestDelegate

/// Extends StoreManager to conform to SKRequestDelegate.
extension StoreManager: SKRequestDelegate {
    /// Called when the product request failed.
    func request(_ request: SKRequest, didFailWithError error: Error) {
        DispatchQueue.main.async {
//            self.delegate?.storeManagerDidReceiveMessage(error.localizedDescription)
        }
    }
}
