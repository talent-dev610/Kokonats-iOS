//
//  TournamentDetailRulesTableViewCell.swift
//  kokonats
//
//  Created by yifei.zhou on 2021/09/29.
//

import UIKit

class TournamentDetailRulesTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var rankingTitle: UILabel!
    @IBOutlet weak var prizeLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.font = UIFont.getKokoFont(type: .regular, size: 14)
        rankingTitle.font = UIFont.getKokoFont(type: .black, size: 14)
        prizeLabel.font = UIFont.getKokoFont(type: .black, size: 28)
    }

    func update(start: String, end: String, score: String) {
        if start == end {
            rankingTitle.text = "\(start)位"
        } else {
            rankingTitle.text = "\(start)位ー\(end)位"
        }
        prizeLabel.text = "+ \(score)"
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
