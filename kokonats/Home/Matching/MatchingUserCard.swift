//
//  MatchingUserCard.swift
//  kokonats
//
//  Created by JR20233 on 2021/10/05.
//

import UIKit

class MatchingUserCard: UIView {
    private let avatarImageView = UIImageView()
    private var userNameLabel: UILabel!

    var userName: String? {
        get {
            userNameLabel.text
        }
        set {
            userNameLabel.text = newValue
        }
    }
    var image: UIImage? {
        get {
            avatarImageView.image
        }
        set {
            avatarImageView.image = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        userNameLabel = UILabel.formatedLabel(size: 16, text: "", type: .black, textAlignment: .center)
        userNameLabel.adjustsFontSizeToFitWidth = true
        userNameLabel.minimumScaleFactor = 0.75
        userNameLabel.textColor = UIColor(named: "fff")

        let stackView = UIStackView(arrangedSubviews: [avatarImageView, userNameLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24
        addSubview(stackView)

        setupAvatarImageView()

        stackView.activeConstraints(directions: [.centerX, .leading(), .centerY])

        backgroundColor = UIColor(named: "cardBg")
        cornerRadius = 20
    }

    private func setupAvatarImageView() {
        avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        avatarImageView.contentMode = .scaleAspectFit

        let avatarSize = CGFloat(90)
        avatarImageView.addConstraints([
            avatarImageView.heightAnchor.constraint(equalToConstant: avatarSize),
            avatarImageView.widthAnchor.constraint(equalToConstant: avatarSize)
        ])
        avatarImageView.cornerRadius = avatarSize / 2
    }
}
