////  TournamentHistoryView.swift
//  kokonats
//
//  Created by sean on 2021/12/07.
//  
//

import Foundation
import UIKit

class TournamentHistoryView: UIView {
    private var tableView: UITableView!
    private var historyTableView: UITableView!
//    private let selectableButton = UIButton()
    var scoreLable: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }

    func update(dataSource: UITableViewDataSource, delegate: UITableViewDelegate) {
        historyTableView.dataSource = dataSource
        historyTableView.delegate = delegate
        historyTableView.reloadData()
    }

    func update(koko: String) {
        scoreLable.text = "+ \(koko)"
    }

    func reloadHistory() {
        historyTableView.reloadData()
    }

    func configureLayout() {
        let titleLabel = UILabel.formatedLabel(size: 34, text: "user_tnmhistory_all_title".localized, type: .bold, textAlignment: .left)
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        addSubview(titleLabel)
        titleLabel.activeConstraints(directions: [.leading(.leading, 24), .top(.top, 103), .trailing(.trailing, -100)])
        titleLabel.activeSelfConstrains([.height(90)])

        let kokoIcon = UIImageView.fromImage(name: "dollar_icon")
        addSubview(kokoIcon)
        kokoIcon.contentMode = .scaleAspectFit

        kokoIcon.activeConstraints(to: titleLabel, directions: [.top(.bottom, 49)])
        kokoIcon.activeSelfConstrains([.width(18), .height(18)])

        let scoreTitle = UILabel.formatedLabel(size: 14, text: "user_tnmhistory_all_allScore_title".localized, type: .bold, textAlignment: .left)
        scoreTitle.textColor = .lightWhiteFontColor
        addSubview(scoreTitle)
        scoreTitle.activeConstraints(to: kokoIcon, directions: [.bottom(.top, -6), .leading(.leading, 30)])
        scoreTitle.activeSelfConstrains([.height(19)])


        let iConLeadingConstraint = kokoIcon.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 180)
        iConLeadingConstraint.priority = UILayoutPriority(1000)
        iConLeadingConstraint.isActive = true

        scoreLable = UILabel.formatedLabel(size: 20, type: .bold, textAlignment: .right)
        addSubview(scoreLable)
        scoreLable.textColor = .kokoYellow
        scoreLable.adjustsFontSizeToFitWidth = true
        scoreLable.numberOfLines = 1
        scoreLable.activeConstraints(to: kokoIcon, directions: [.centerY, .leading(.trailing, 6)])
        scoreLable.activeConstraints(directions: [.trailing(.trailing, -24)])
        scoreLable.activeSelfConstrains([.height(40)])

        historyTableView = UITableView()
        historyTableView.showsVerticalScrollIndicator = false
        historyTableView.backgroundColor = .kokoBgColor
        historyTableView.tableFooterView = UIView()
        addSubview(historyTableView)
        historyTableView.activeConstraints(directions: [.leading(.leading, 24), .centerX, .bottom()])
        historyTableView.activeConstraints(to: scoreLable, directions: [.top(.bottom, 37)])
        historyTableView.estimatedRowHeight = 90
        historyTableView.register(TournamentHistoryItemTableViewCell.self, forCellReuseIdentifier: "TournamentHistoryItemTableViewCell")
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
