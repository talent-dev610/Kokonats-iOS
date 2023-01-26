////  GameListCollectionViewCell.swift
//  kokonats
//
//  Created by sean on 2021/11/03.
//  
//

import Foundation
import UIKit

class GameListCollectionViewCell: UICollectionViewCell {
    private var coverImage: UIImageView!
    var playLabel: UILabel!
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        coverImage.image = nil
    }

    private func prepareLayout() {
        contentView.layer.cornerRadius = 20
        contentView.layer.shadowOffset = CGSize(width: 4, height: 4)
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.25

        coverImage = UIImageView()
        coverImage.backgroundColor = .lightBgColor
        contentView.addSubview(coverImage)
        coverImage.activeConstraints(directions: [.top(), .leading()])
        coverImage.contentMode = .scaleAspectFit
        coverImage.activeSelfConstrains([.height(150), .width(255)])
        coverImage.layer.cornerRadius = 20
        coverImage.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        coverImage.clipsToBounds = true

        playLabel = UILabel.formatedLabel(size: 16, text: "home_game_card_title".localized)
        playLabel.backgroundColor = .lightBgColor
        contentView.addSubview(playLabel)
        playLabel.activeConstraints(to: coverImage, directions: [.leading(), .trailing(), .top(.bottom, 0)])
        playLabel.activeSelfConstrains([.height(38)])
        playLabel.layer.cornerRadius = 20
        playLabel.clipsToBounds = true
        playLabel.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    func configure(with image: UIImage?, index: Int, imageName: String) {
        coverImage.image = image
    }
}
