//
//  StoreNewTableViewCells.swift
//  kokonats
//
//  Created by George on 5/5/22.
//

import Foundation
import UIKit

class EnergyListCell: UITableViewCell {
    
    private var titleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        let containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.shadow(offset: CGSize(width: 0, height: 8), radius: 8, color: UIColor.black.cgColor, opacity: 0.2)
        containerView.backgroundColor = .lightBgColor
        contentView.addSubview(containerView)
        containerView.activeConstraints(to: contentView, directions: [.leading(.leading, 24), .trailing(.trailing, -24), .top(.top, 10), .bottom(.bottom, -10)])
        
        let iconImage = UIImageView(image: UIImage(named: "inapp_purchase_icon"))
        iconImage.backgroundColor = .clear
        containerView.addSubview(iconImage)
        iconImage.activeConstraints(to: containerView, directions: [.leading(.leading, 16), .centerY])
        iconImage.contentMode = .scaleAspectFit
        iconImage.activeSelfConstrains([.width(60), .height(60)])
        
        titleLabel = UILabel.formatedLabel(size: 18, text: "", type: .medium, textAlignment: .left)
        titleLabel.textColor = .kokoYellow
        containerView.addSubview(titleLabel)
        titleLabel.activeConstraints(to: iconImage, directions: [.leading(.trailing, 23), .centerY])
        
        let arrowImage = UIImageView(image: UIImage(systemName: "greaterthan"))
        arrowImage.backgroundColor = .clear
        containerView.addSubview(arrowImage)
        arrowImage.activeConstraints(to: containerView, directions: [.trailing(.trailing, -12), .centerY])
        arrowImage.contentMode = .scaleToFill
        arrowImage.image = arrowImage.image?.withRenderingMode(.alwaysTemplate)
        arrowImage.tintColor = .textBgColor
        arrowImage.activeSelfConstrains([.width(12), .height(26)])
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateEnergyItem(_ item: EnergyItem) {
        titleLabel.text = item.energyItemName
    }
}

class ItemsListCell: UITableViewCell {
    
    private var iconImage: UIImageView!
    private var titleLabel: UILabel!
    

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        
        let containerView = UIView()
        containerView.layer.cornerRadius = 10
        containerView.shadow(offset: CGSize(width: 0, height: 8), radius: 8, color: UIColor.black.cgColor, opacity: 0.2)
        containerView.layer.shadowOffset = CGSize(width: 4, height: 4)
        containerView.layer.shadowRadius = 4
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.25
        containerView.backgroundColor = .itemListBg
        contentView.addSubview(containerView)        
        containerView.activeConstraints(to: contentView, directions: [.leading(.leading, 24), .trailing(.trailing, -24), .top(.top, 10), .bottom(.bottom, -10)])
        
        iconImage = UIImageView()
        iconImage.backgroundColor = .clear
        containerView.addSubview(iconImage)
        iconImage.activeConstraints(to: containerView, directions: [.leading(.leading, 10), .centerY])
        iconImage.contentMode = .scaleAspectFit
        iconImage.activeSelfConstrains([.width(60), .height(60)])
        
        titleLabel = UILabel.formatedLabel(size: 18, text: "Game Title",type:.bold, textAlignment: .left)
        titleLabel.textColor = .kokoBgColor
        containerView.addSubview(titleLabel)
        titleLabel.activeConstraints(to: iconImage, directions: [.leading(.trailing, 20), .centerY])
        
        let arrowImage = UIImageView(image: UIImage(systemName: "greaterthan"))
        arrowImage.backgroundColor = .clear
        containerView.addSubview(arrowImage)
        arrowImage.activeConstraints(to: containerView, directions: [.trailing(.trailing, -12), .centerY])
        arrowImage.contentMode = .scaleToFill
        arrowImage.image = arrowImage.image?.withRenderingMode(.alwaysTemplate)
        arrowImage.tintColor = .textBgColor
        arrowImage.activeSelfConstrains([.width(12), .height(26)])
        
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateGameItem(_ item: GameDetail) {
        updateThumbnail(url: item.iconUrl ?? "")
        titleLabel.text = item.name
    }
    
    private func updateThumbnail(url: String) {
        if !url.isEmpty {
            ImageCacheManager.shared.loadImage(urlString: url) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            self?.iconImage.image = image
                        } else {
                            Logger.debug("failed to get image data")
                        }
                    case .failure(let error):
                        Logger.debug("\(error)")
                        break
                    }
                }
            }
        } else {
            iconImage.image = UIImage(named: "game_thumbnail_sample")
        }
    }
}


class LabelCell: UITableViewCell {    

    private var titleLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .kokoBgColor
        
        titleLabel = UILabel.formatedLabel(size: 34, text: "shop_item_title".localized, type: .bold)
        titleLabel.textAlignment = .left
        titleLabel.textColor = .white
        contentView.addSubview(titleLabel)
        titleLabel.activeConstraints(to: contentView, directions: [.leading(.leading, 24), .centerX, .bottom(.bottom, -10)])
        titleLabel.activeSelfConstrains([.height(44)])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(_ title: String) {
        titleLabel.text = title
    }
}
