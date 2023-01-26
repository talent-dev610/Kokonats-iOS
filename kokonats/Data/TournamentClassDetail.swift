////  TournamentDetail.swift
//  kokonats
//
//  Created by sean on 2021/09/25.
//  
//

import Foundation

struct TournamentClassDetail: Codable {
    let id: Int
    let gameId: Int
    let tournamentName: String?
    let thumbnail: String?
    let coverImageUrl: String?
    let description: String?
    let type: Int
    let startTime: String?
    let durationSecond: Int?
    let durationPlaySecond: Int?
    let entryFee: Int?
    let entryBeforeSecond: Int?
    let participantNumber: Int?
    let rankingPayout: String?
    let keyword: String?
    let tag: String?

    var tags: [String] {
        if let tagString = tag, !tagString.isEmpty {
            let taglist = tagString.split(separator: ",").map{ String($0) }
            return taglist
        }
        return [String]()
    }

//  "[{\"startRank\": \"1\", \"endRank\": \"1\", \"payout\": 1000},{\"startRank\": \"2\", \"endRank\": \"3\", \"payout\": 400},{\"startRank\": \"4\", \"endRank\": \"14\", \"payout\": 100}]"
    var kokoReward: Int? {
        guard let rankingPayout = rankingPayout else {
            return nil
        }
        do {
            if let json = try JSONSerialization.jsonObject(with: Data(rankingPayout.utf8), options: []) as? [JSONObject] {
                let list = json.sorted(by: {
                    let first = Int($0["startRank"] as? String ?? "99") ?? 99
                    let second = Int($1["startRank"] as? String ?? "99") ?? 99
                    return first < second
                })

                let koko: Int? = list.first.flatMap {
                    return $0["payout"] as? Int ?? 0
                }
                return koko
            } else {
                return nil
            }
        } catch {
            Logger.debug("failed to decode rankingPayout")
            return nil
        }
    }
}
