////  TournamentDetailView.swift
//  kokonats
//
//  Created by sean on 2022/01/09.
//  
//

import Foundation
import UIKit

class TournamentDetailView: UIView {
    private var thumbnailView: UIImageView!
    private var joinButtonLabel: UILabel!
    private var rankingTableView: UITableView!
    private var rulesTableView: UITableView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepareLayout() {
        thumbnailView = UIImageView()
        thumbnailView.contentMode = .scaleAspectFit
        thumbnailView.backgroundColor = .kokoBgColor
        addSubview(thumbnailView)
        thumbnailView.activeConstraints(directions: [.top(), .leading(.leading, 24), .centerX])
        thumbnailView.widthAnchor.constraint(equalTo: thumbnailView.heightAnchor, multiplier: 1.0).isActive = true

        thumbnailView.clipsToBounds = true
        thumbnailView.layer.cornerRadius = 10

        let backgroundView = UIView()
        addSubview(backgroundView)
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 10

        backgroundView.activeConstraints(to: thumbnailView, directions: [.leading(), .top(.bottom, 19), .centerX])
        backgroundView.activeSelfConstrains([.height(48)])
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: screenSize.width - 48, height: 48)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [UIColor.bannerBlue.cgColor, UIColor.bannerPurple.cgColor]
        backgroundView.layer.insertSublayer(gradientLayer, at: 0)

        joinButtonLabel = UILabel.formatedLabel(size: 14, text: "join_game".localized, type: .black, textAlignment: .center)
        addSubview(joinButtonLabel)
        joinButtonLabel.activeConstraints(to: thumbnailView, directions: [.leading(), .top(.bottom, 19), .centerX])
        joinButtonLabel.activeSelfConstrains([.height(48)])
        joinButtonLabel.backgroundColor = .clear

        let ruleTitle = UILabel.formatedLabel(size: 14, text: "rule_title".localized, type: .regular, textAlignment: .left)
        addSubview(ruleTitle)
        ruleTitle.activeConstraints(to: joinButtonLabel, directions: [.leading(), .top(.bottom, 40)])
        ruleTitle.activeSelfConstrains([.width(100), .height(19)])

        rulesTableView = buildTableView()
        addSubview(rulesTableView)
        rulesTableView.activeConstraints(to: ruleTitle, directions: [.leading(), .top(.bottom, 8), .centerX])
        rulesTableView.estimatedRowHeight = 40
        rulesTableView.register(TournamentDetailRulesTableViewCell.self, forCellReuseIdentifier: "TournamentDetailRulesTableViewCell")
        rulesTableView.isScrollEnabled = false
    }

    private func buildTableView() -> UITableView {
        let tableView = UITableView()
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .kokoBgColor
        tableView.tableFooterView = UIView()
        tableView.separatorStyle = .none
        return tableView
    }
}
