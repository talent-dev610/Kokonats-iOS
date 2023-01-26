////  TagCollectionViewCell.swift
//  kokonats
//
//  Created by sean on 2021/11/09.
//  
//

import UIKit

class TagCollectionViewCell: UICollectionViewCell {
    private var tagLabel: UILabel!
    private var leadingContraint: NSLayoutConstraint!
    private var isConfigured: Bool = false
    private var iconAll: UIImageView?

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }

    private func prepare() {
        contentView.layer.cornerRadius = 19
        contentView.clipsToBounds = true
        contentView.backgroundColor = .lightBgColor
        tagLabel = UILabel.formatedLabel(size: 17, type: .bold)
        tagLabel.backgroundColor = .clear
        tagLabel.textAlignment = .center
        contentView.addSubview(tagLabel)
        tagLabel.activeConstraints(directions: [.top(), .bottom(), .trailing(.trailing, -20)])
        tagLabel.activeSelfConstrains([.height(38)])
        leadingContraint = tagLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20)
        leadingContraint.priority = UILayoutPriority(750)
        leadingContraint.isActive = true
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with tag: String) {
        iconAll?.removeFromSuperview()
        iconAll = nil
        tagLabel.text = ""
        if tag == "all_tag".localized {
            let icon = UIImageView(image: UIImage(named: "all_tag_icon"))
            contentView.addSubview(icon)
            icon.activeConstraints(directions: [.leading(.leading, 8), .centerY])
            icon.activeSelfConstrains([.height(18), .width(18)])

            let constraint = tagLabel.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 8)
            constraint.priority = UILayoutPriority(1000)
            constraint.isActive = true
            iconAll = icon
        } else {
            tagLabel.text = tag
        }
        isConfigured = true
        tagLabel.text = tag

    }

    override var isSelected: Bool {
        didSet {
            let color: UIColor = isSelected ? .selectedColor : .lightBgColor
            contentView.backgroundColor = color
        }
    }
}
