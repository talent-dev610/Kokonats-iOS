////  TournamentHistory.swift
//  kokonats
//
//  Created by sean on 2021/11/07.
//  
//

import Foundation

struct TournamentHistoryItem: Codable {
    let id: Int
    let tournamentClassId: Int
    let tournamentName: String
    let gameId: Int
    let startTime: String
    let durationSecond: Int
    let entryBeforeSecond: Int
    let entryFee: Int
    let participantNumber: Int
    let rankingPayout: String
    let keyword: String
    let tag: String
}
