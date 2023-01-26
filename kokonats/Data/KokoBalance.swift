////  KokoBalance.swift
//  kokonats
//
//  Created by sean on 2022/01/20.
//
//

import Foundation
struct KokoBalance: Codable {
    let address: String
    let confirmed: String
    let unconfirmed: String
}
