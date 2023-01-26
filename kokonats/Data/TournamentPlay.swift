////  TournamentHistory.swift
//  kokonats
//
//  Created by sean on 2021/10/29.
//  
//

import Foundation

struct TournamentPlay: Codable {
    let id: Int
    let tournamentId: Int
    let tournamentName: String?
    let userName: String?
    let gameId: Int?
    let score: Int?
    let finalRank: Int?
}
