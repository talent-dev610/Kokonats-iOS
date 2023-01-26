////  UserTournamentHistoryItem.swift
//  kokonats
//
//  Created by sean on 2022/01/08.
//  
//

struct UserTournamentHistoryItem: Codable {
    let id: Int
    let tournamentId: Int?
    let matchId: String?
    let tournamentName: String?
    let matchName: String?
    let userName: String?
    let gameId: Int?
    let score: Int?
    let finalRank: Int?
    let energy: Int?
    let kokoAmount: Int?
    let result: String?
    let picture: String?
    let timestamp: Int?
    let type: Int?
}
