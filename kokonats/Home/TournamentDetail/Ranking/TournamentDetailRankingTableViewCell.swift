//
//  TournamentDetailRankingTableViewCell.swift
//  kokonats
//
//  Created by yifei.zhou on 2021/10/05.
//

import UIKit

class TournamentDetailRankingTableViewCell: UITableViewCell {
    struct RankingData {
        let order: Int
        let userName: String
        let score: String
    }

    @IBOutlet weak var rankingView: UIView!
    @IBOutlet weak var rankingLabel: UILabel!
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userNameLabel.font = UIFont.getKokoFont(type: .medium, size: 14)
        scoreLabel.font = UIFont.getKokoFont(type: .black, size: 28)
        rankingLabel.font = UIFont.getKokoFont(type: .bold, size: 18)
        rankingLabel.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func updateData(_ data: RankingData) {
        userNameLabel.text = data.userName
        scoreLabel.text = data.score
        let order: String = {
            if data.order < 10 {
                return "0\(data.order)"
            } else {
                return "\(data.order)"
            }
        }()
        switch data.order {
        case 1:
            rankingView.backgroundColor = .firstScoreBg
        case 2:
            rankingView.backgroundColor = .secondScoreBg
        case 3:
            rankingView.backgroundColor = .thirdScoreBg
        default:
            rankingView.backgroundColor = .lightBgColor
        }
        rankingLabel.text = order
    }
}
