//
//  TournamentDetailRulesDelegate.swift
//  kokonats
//
//  Created by yifei.zhou on 2021/09/29.
//

import UIKit

final class TournamentDetailRulesDelegate: NSObject, UITableViewDataSource, UITableViewDelegate {
    var rankingRules = [JSONObject]()

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rankingRules.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tournamentDetailRulesCell") as! TournamentDetailRulesTableViewCell
        let rankingRule = rankingRules[indexPath.row]
        cell.update(start: rankingRule["startRank"] as? String ?? "",
                    end: rankingRule["endRank"] as? String ?? "",
                    score: String(rankingRule["payout"] as? Int ?? 0))
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
}
