//
//  TournamentSupportTableViewCell.swift
//  kokonats
//
//  Created by George on 5/16/22.
//

import Foundation
import UIKit

final class TournamentSupportTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepareLayout() {
        contentView.backgroundColor = .kokoBgColor
        contentView.clipsToBounds = true

        let bgView = UIView()
        bgView.backgroundColor = UIColor(red: 50/255, green: 55/255, blue: 85/255, alpha: 1)
        bgView.layer.cornerRadius = 10
        contentView.addSubview(bgView)
        bgView.activeConstraints()

        let label = UILabel.formatedLabel(size: 14, text: "user_tnmhistory_support".localized, type: .bold, textAlignment: .center)
        contentView.addSubview(label)
        label.activeConstraints(directions: [.top(.top, 1), .leading(.leading, 1), .bottom(.bottom, -1), .trailing(.trailing, -1)])
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        label.backgroundColor = .kokoBgColor
    }
}
