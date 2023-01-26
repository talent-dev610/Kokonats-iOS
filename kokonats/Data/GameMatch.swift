////  GameMatchingResult.swift
//  kokonats
//
//  Created by sean on 2022/01/21.
//  
//

struct GameMatch: Codable {
    let id: Int
    let gameId: Int
    let matchName: String?
    let thumbnail: String?
    let coverImageUrl: String?
    let description: String?
    let type: Int?
    let matchingSecond: Int?
    let durationSecond: Int?
    let entryFee: Int?
    let winningPayout: Int?
    let keyword: String?
    let tag: String?
}
