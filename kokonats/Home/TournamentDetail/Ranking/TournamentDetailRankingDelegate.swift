//
//  TournamentDetailRankingDelegate.swift
//  kokonats
//
//  Created by yifei.zhou on 2021/10/05.
//

import UIKit

final class TournamentDetailRankingDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    var currentRankings = [TournamentPlay]()
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return currentRankings.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tournamentDetailRanking") as! TournamentDetailRankingTableViewCell
        let rankingInfo = currentRankings[indexPath.row]
        cell.updateData(TournamentDetailRankingTableViewCell.RankingData(order: indexPath.row + 1,
                                                                         userName: rankingInfo.userName ?? "",
                                                                         score: rankingInfo.score?.formatedString() ?? "" ))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
}

