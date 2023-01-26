////  TournamentHistoryItemTableViewCell.swift
//  kokonats
//
//  Created by sean on 2021/11/16.
//  
//

import Foundation
import UIKit

final class TournamentHistoryItemTableViewCell: UITableViewCell {

    struct DataModel {
        let title: String
        let date: String?
        let koko: Int
        let spentEnergy: Int
    }

    private var titleLable: UILabel!
    private var dateLabel: UILabel!
    private var scoreLable: UILabel!
    private var energyLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareLayout()
    }

    private func prepareLayout() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.layer.cornerRadius = 10
        contentView.backgroundColor = .lightBgColor
        titleLable = UILabel.formatedLabel(size:12, type: .bold, textAlignment: .left)
        titleLable.textColor = .lightWhiteFontColor
        contentView.addSubview(titleLable)
        titleLable.activeSelfConstrains([.height(22)])
        titleLable.activeConstraints(directions: [.leading(.leading, 18)])
        titleLable.activeConstraints(directions: [.top(.top, 9), .trailing(.trailing, 80)])

        let kokoIcon = UIImageView(image: UIImage(named: "dollar_icon"))
        kokoIcon.contentMode = .scaleAspectFill

        contentView.addSubview(kokoIcon)
        kokoIcon.activeConstraints(directions: [.top(.top, 37), .leading(.leading, 18)])
        kokoIcon.activeSelfConstrains([.width(18), .height(18)])

        scoreLable = UILabel.formatedLabel(size: 20, type: .black, textAlignment: .left)
        scoreLable.textColor = .kokoYellow
        contentView.addSubview(scoreLable)
        scoreLable.activeConstraints(to: kokoIcon, directions: [.leading(.trailing, 6), .centerY])
        scoreLable.activeSelfConstrains([.height(28)])
        scoreLable.activeConstraints(directions: [.trailing(.trailing, 80)])

        dateLabel = UILabel.formatedLabel(size: 10, textAlignment: .left)
        dateLabel.textColor = .lightWhiteFontColor
        contentView.addSubview(dateLabel)
        dateLabel.activeSelfConstrains([.height(22)])
        dateLabel.activeConstraints(to: kokoIcon, directions: [.leading()])
        dateLabel.activeConstraints(to: scoreLable, directions: [.top(.bottom), .trailing()])
        
        // Energy
        let energyView = UIView()
        let energyViewHeight: CGFloat = 20
        energyView.backgroundColor = UIColor.kokoGreenStamp.withAlphaComponent(0.1)
        energyView.cornerRadius = energyViewHeight / 2
        contentView.addSubview(energyView)
        energyView.activeSelfConstrains([.height(energyViewHeight)])
        energyView.activeConstraints(to: titleLable, directions: [.centerY])
        energyView.activeConstraints(to: contentView, directions: [.trailing(.trailing, -10)])
        
        let energyIcon = UIImageView(image: UIImage(named: "energy_icon"))
        energyIcon.contentMode = .scaleAspectFit
        energyView.addSubview(energyIcon)
        energyIcon.activeSelfConstrains([.width(7.5), .height(14)])
        energyIcon.activeConstraints(to: energyView, directions: [.leading(.leading, 8), .centerY])
        
        energyLabel = UILabel.formatedLabel(size: 12, type: .bold, textAlignment: .center)
        energyLabel.textColor = .kokoGreenStamp
        energyView.addSubview(energyLabel)
        energyLabel.activeConstraints(to: energyView, directions: [.centerY, .trailing(.trailing, -5)])
        energyLabel.activeConstraints(to: energyIcon, directions: [.leading(.trailing, 4)])
    }

    func updateView(_ dataModel: DataModel) {
        titleLable.text = dataModel.title
        scoreLable.text = "+ \(dataModel.koko.formatedString())"
        dateLabel.text = dataModel.date?.description
        energyLabel.text = dataModel.spentEnergy == 0 ? "0" : "-\(dataModel.spentEnergy)"
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
