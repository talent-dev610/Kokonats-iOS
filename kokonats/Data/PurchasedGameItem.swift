////  ProductItem.swift
//  kokonats
//
//  Created by sean on 2022/03/16.
//  
//

import Foundation

struct PurchasedGameItem: Codable {
    let id: Int
    let gameId: Int
    let gameItemId: Int?
    let kokoPrice: Int?
    let gameItemName: String?
}

struct GameItem: Codable {
    let id: Int
    let gameId: Int
    let name: String
    let pictureUrl: String?
    let kokoPrice: Int?
}
