////  BlacklistItemTableViewCell.swift
//  kokonats
//
//  Created by sean on 2021/12/24.
//
//

import Foundation
import UIKit

class BlacklistItemTableViewCell: UITableViewCell {
    public var useravatar: UIImageView!
    public var usernameLable: UILabel!
    public var blockedDateLabel: UILabel!
    public var moreButton = UIButton(type: .custom)
    var buttonTapCallback: () -> ()  = { }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        prepareLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepareLayout() {
        contentView.isUserInteractionEnabled = true
        selectionStyle = .none
        backgroundColor = .clear
        
        useravatar = UIImageView(image: UIImage(named: "avatar_5"))
        addSubview(useravatar)
        useravatar.activeConstraints(directions: [.leading(.leading, 0), .centerY])
        useravatar.activeSelfConstrains([.height(48), .width(48)])
        useravatar.clipsToBounds = true

        usernameLable = UILabel.formatedLabel(size: 16, text: "", type: .black, textAlignment: .left)
        addSubview(usernameLable)
        usernameLable.activeConstraints(to: useravatar, directions: [.leading(.trailing, 14)])
        usernameLable.activeConstraints(directions: [.top(), .trailing(.trailing, 0)])
        usernameLable.activeSelfConstrains([.height(48)])
        usernameLable.textColor = .white

        blockedDateLabel = UILabel.formatedLabel(size: 14, text: "", type: .regular, textAlignment: .left)
        addSubview(blockedDateLabel)
        blockedDateLabel.activeConstraints(to: useravatar, directions: [.leading(.trailing, 19)])
        blockedDateLabel.activeConstraints(directions: [.bottom()])
        blockedDateLabel.activeSelfConstrains([.height(48)])
        blockedDateLabel.textColor = .white
        
        moreButton.setImage(UIImage(named: "More"), for: .normal)
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
        addSubview(moreButton)
        moreButton.activeSelfConstrains([.width(40), .height(40)])
        moreButton.activeConstraints(directions: [.trailing(.trailing, 0), .centerY])
    }
    @objc func didTapMoreButton() {
        buttonTapCallback()
    }

}
