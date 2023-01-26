//
//  StoreEnergyListCollectionViewCell.swift
//  kokonats
//
//  Created by George on 2022-05-05.
//

import Foundation
import UIKit

class StoreEnergyListCollectionViewCell: UICollectionViewCell {
    
    private var energyLabel: UILabel!
    private var priceLabel: UILabel!
    private var recommendLabel: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    private func prepareLayout() {
        backgroundColor = .lightBgColor
        layer.cornerRadius = 10
        shadow(offset: CGSize(width: 0, height: 8), radius: 8, color: UIColor.black.cgColor, opacity: 0.2)
        
        recommendLabel = UILabel.formatedLabel(size: 12, text: "recommended".localized, type: .bold, textAlignment: .center)
        contentView.addSubview(recommendLabel)
        recommendLabel.textColor = .white
        recommendLabel.activeSelfConstrains([.width(110), .height(20)])
        recommendLabel.backgroundColor = .recommendedEnergyColor
        recommendLabel.cornerRadius = 10
        recommendLabel.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        recommendLabel.activeConstraints(directions: [.top(), .leading(), .trailing()])
        
        let imageView = UIImageView(image: UIImage(named: "inapp_purchase_icon"))
        contentView.addSubview(imageView)
        imageView.activeConstraints(directions: [.top(.top, 20), .centerX])
        imageView.activeSelfConstrains([.width(60), .height(60)])

        energyLabel = UILabel.formatedLabel(size: 14, text: "", textAlignment: .center)
        contentView.addSubview(energyLabel)
        energyLabel.activeConstraints(to: imageView, directions: [.top(.bottom, 6), .centerX])
        energyLabel.activeSelfConstrains([.height(17), .width(95)])

        priceLabel = UILabel.formatedLabel(size: 20, text: "", textAlignment: .center)
        contentView.addSubview(priceLabel)
        priceLabel.activeConstraints(to: energyLabel, directions: [.centerX, .top(.bottom, 4)])
        priceLabel.activeSelfConstrains([.height(22), .width(60)])
        contentView.isUserInteractionEnabled = true
    }
    
    func update(energyItem: KokoProductType, hideRecommend: Bool) {
        energyLabel.text = "+ \(energyItem.energy)"
        priceLabel.text = "¥ \(energyItem.price)"
        recommendLabel.isHidden = hideRecommend
    }
}
