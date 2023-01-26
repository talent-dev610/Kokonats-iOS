////  VerificationResult.swift
//  kokonats
//
//  Created by sean on 2021/12/10.
//  
//

import Foundation

struct VerificationResult: Codable {
    let receiptId: String
    let receipt: String?
    let platform: String?
    let productId: Int?
    let state: Int
}
