////  StoreGameListCollectionViewCell.swift
//  kokonats
//
//  Created by sean on 2022/03/16.
//  
//

import Foundation
import UIKit

final class StoreGameListCollectionViewCell: UICollectionViewCell {
    private var iconImage: UIImageView!

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepareLayout() {
        contentView.layer.cornerRadius = 19
        contentView.clipsToBounds = true
        iconImage = UIImageView()
        iconImage.backgroundColor = .lightBgColor
        contentView.addSubview(iconImage)
        iconImage.activeConstraints()

    }

    func updateStatus(isSelected: Bool) {
        iconImage.alpha = isSelected ? 0.5: 1
    }

    func updateIcon(with image: UIImage) {
        iconImage.image = image
    }
}

