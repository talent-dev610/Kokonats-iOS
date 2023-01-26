////  MatchResult.swift
//  kokonats
//
//  Created by sean on 2022/01/24.
//  
//

import Foundation

struct MatchResult: Codable {
    let matchId: String
    let result: String?
    let state: Int?
    let energy: Int?
    let kokoAmount: Int?
    let players: [MatchPlayer]
}

struct MatchPlayer: Codable {
    let username: String
    let picture: String
    let subscriber: String
    let totalScore: Int
    let state: Int
}

