////  RankingTableViewCell.swift
//  kokonats
//
//  Created by sean on 2021/12/24.
//  
//

import Foundation
import UIKit

class RankingTableViewCell: UITableViewCell {
    private var rankingLabel: UILabel!
    private var scoreLabel: UILabel!
    private var usernameLable: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateData(ranking: String, score: Int, name: String, isCurrentUser: Bool = false) {
        rankingLabel.text = ranking
        scoreLabel.text = score.formatedString()
        usernameLable.text = name
        rankingLabel.backgroundColor = isCurrentUser ? .kokoLightYellow : .rankingLightWhite
        rankingLabel.textColor = isCurrentUser ? .kokoYellow : .white
        scoreLabel.textColor = isCurrentUser ? .kokoYellow : .white
        usernameLable.textColor = isCurrentUser ? .kokoYellow : .white
    }

    private func prepareLayout() {
        selectionStyle = .none
        backgroundColor = .clear
        rankingLabel = UILabel.formatedLabel(size: 14, text: "", type: .black, textAlignment: .center)
        addSubview(rankingLabel)
        rankingLabel.activeConstraints(directions: [.leading(.leading, 20), .centerY])
        rankingLabel.activeSelfConstrains([.height(36), .width(36)])
        rankingLabel.layer.cornerRadius = 18
        rankingLabel.backgroundColor = .rankingLightWhite
        rankingLabel.clipsToBounds = true

        scoreLabel = UILabel.formatedLabel(size: 16, text: "", type: .black, textAlignment: .left)
        addSubview(scoreLabel)
        scoreLabel.activeConstraints(to: rankingLabel, directions: [.leading(.trailing, 9)])
        scoreLabel.activeConstraints(directions: [.top(), .trailing(.trailing, -36)])
        scoreLabel.activeSelfConstrains([.height(24)])

        usernameLable = UILabel.formatedLabel(size: 14, text: "", type: .regular, textAlignment: .left)
        addSubview(usernameLable)
        usernameLable.activeConstraints(to: scoreLabel, directions: [.leading()])
        usernameLable.activeConstraints(directions: [.bottom()])
        usernameLable.activeSelfConstrains([.height(20)])
    }
}
