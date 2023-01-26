//
//  TournamentStatusDetector.swift
//  kokonats
//
//  Created by 閑野伊織 on 2022/02/12.
//

import Foundation

// Determine if a tournament is being held and if there is space available.
// If we do polling in the future, should upgrade to Manager and take on this class.
class TournamentStatusDetector: NSObject {
    
    enum TournamentStatus {
        case playable, finished, notStartedYet, full
    }
    
    // ref: https://github.com/BiiiiiT-Inc/koko-iOS/issues/75
    class func detect(tournament: PlayableTournamentDetail, tournamentClass: TournamentClassDetail, joinedAlready: Bool) -> TournamentStatus {
        guard tournamentClass.type == 1 else { return .playable }
        // NOTE: tournament.startTime is null, so we use tournamentClass.startTime, durationSecond and entryBeforeSecond
        guard var startDate = tournamentClass.startTime?.kokoTimeStrToDate() else { return .finished }
        
        let durationSecond = tournamentClass.durationSecond ?? 0
        let entryBeforeSecond = tournamentClass.entryBeforeSecond ?? 0
        let duration = durationSecond - entryBeforeSecond
        let current = Date()

        // Because tournament is available means current > start
        if current < startDate {
            // Start from yesterday
            startDate = startDate.added(day: -1)
        }

        let endDate = startDate.added(second: duration)
        
        if current > endDate {
            return .finished
        }

        if current > startDate {
          if let participantCount = tournament.participantNumber {
              if joinedAlready {
                  return .playable
              }
              if participantCount == tournament.joinPlayersCount {
                  return .full
                }
            }
            
            return .playable
        }
        
        return .notStartedYet
    }
    
    // tournament が取得できない場合に呼ぶ。 .playable になることはない。
    class func detectRejectReason(tournamentClass: TournamentClassDetail) -> TournamentStatus {
        guard let startDate = tournamentClass.startTime?.kokoTimeStrToDate() else { return .finished }
        
        let endDate = startDate.added(second: (tournamentClass.durationSecond ?? 0) - (tournamentClass.entryBeforeSecond ?? 0))
        let current = Date()
        
        if current > endDate {
            return .finished
        } else if current > startDate {
            return .full // don't return .playable
        }
        
        return .notStartedYet
    }
}
