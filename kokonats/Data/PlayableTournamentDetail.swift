////  PlayableTournamentDetail.swift
//  kokonats
//
//  Created by sean on 2021/10/22.
//  
//

import Foundation

struct PlayableTournamentDetail: Codable {
    let id: Int
    let tournamentClassId: Int
    let tournamentName: String?
    let gameId: Int
    let startTime: String?
    let durationSecond: Int?
    let entryBeforeSecond: Int?
    let entryFee: Int?
    let participantNumber: Int?
    let rankingPayout: String?
    let keyword: String?
    let tag: String?
    let newestJoinPlayers: [NewTournamentPlayer]
    let joinPlayersCount: Int

    struct NewTournamentPlayer: Codable {
        let username: String
        let picture: String
        let subscriber: String
    }
}
