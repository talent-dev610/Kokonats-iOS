////  TournamentListCollectionViewCell.swift
//  kokonats
//
//  Created by sean on 2021/11/03.
//  
//

import Foundation
import UIKit

class TournamentListCollectionViewCell: UICollectionViewCell {
    static let KeywordColors: [UIColor] = [.kokoYellow, .kokoGreen, .kokoRed]
  
    var eventHandler: EventHandler?
    private var entryFeeLabel: UILabel!
    private var tournamentTitle: UILabel!
    private var tournamentIntro: UILabel!
    private var thumbnailView: UIImageView!
    private var playButton: UIView!
    private var keywordStackView: UIStackView!
    private var keywordLabels: [UILabel] = []
    private var playerCountLabel: UILabel!
    private var koko: UILabel!
    private var playerCountIcon: UIImageView!

    struct ViewData {
        let thumbnail: UIImage
        let tournamentTitle: String
        let tournamentIntro: String
        let keywords: [String]
        let entryFee: Int
        let participantNumber: Int?
        let joinPlayersCount: Int?
        let isPVP: Bool
        let koko: Int
    }


    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func prepareLayout() {
        contentView.layer.cornerRadius = 20
        contentView.backgroundColor = UIColor.lightBgColor

        contentView.layer.shadowOffset = CGSize(width: 4, height: 4)
        contentView.layer.shadowRadius = 4
        contentView.layer.shadowColor = UIColor.black.cgColor
        contentView.layer.shadowOpacity = 0.25

        thumbnailView = UIImageView(image: UIImage())
        contentView.addSubview(thumbnailView)
        thumbnailView.layer.cornerRadius = 10
        thumbnailView.clipsToBounds = true
        thumbnailView.contentMode = .scaleAspectFill
        thumbnailView.activeConstraints(directions:[.top(.top, 20), .centerX, .leading(.leading, 20)])
        thumbnailView.activeSelfConstrains([.height(150), .width(255)])

        let kokoContainerView = UIView()
        kokoContainerView.clipsToBounds = true
        kokoContainerView.layer.cornerRadius = 10
        contentView.addSubview(kokoContainerView)
        kokoContainerView.backgroundColor = .ticketContainerBg
        kokoContainerView.activeSelfConstrains([.height(20)])
        kokoContainerView.activeConstraints(to: thumbnailView, directions: [.top(.top, 10), .trailing(.trailing, -14)])

        let kokoIcon = UIImageView.fromImage(name: "dollar_icon")
        contentView.addSubview(kokoIcon)
        kokoIcon.activeSelfConstrains([.width(15), .height(15)])
        kokoIcon.activeConstraints(to: kokoContainerView, directions: [.leading(.leading, 10), .centerY])

        koko = UILabel.formatedLabel(size: 12, text: "", type: .bold, textAlignment: .center)
        koko.backgroundColor = .clear
        koko.adjustsFontSizeToFitWidth = true
        contentView.addSubview(koko)
        koko.activeSelfConstrains([.height(25)])
        koko.activeConstraints(to: kokoContainerView, directions: [.centerY, .trailing(.trailing, -10)])
        koko.activeConstraints(to: kokoIcon, directions: [.leading(.trailing, 4)])

        let ticketContainerView = UIView()
        ticketContainerView.clipsToBounds = true
        ticketContainerView.layer.cornerRadius = 10
        contentView.addSubview(ticketContainerView)
        ticketContainerView.backgroundColor = .ticketContainerBg
        ticketContainerView.activeSelfConstrains([.height(20), .width(90)])
        ticketContainerView.activeConstraints(to: thumbnailView, directions: [.top(.top, 39), .trailing(.trailing, -14)])

        let ticketIcon = UIImageView.fromImage(name: "energy_icon")
        contentView.addSubview(ticketIcon)
        ticketIcon.activeSelfConstrains([.width(6)])
        ticketIcon.contentMode = .scaleAspectFit
        ticketIcon.activeConstraints(to: ticketContainerView, directions: [.centerY, .leading(.leading, 11)])

        entryFeeLabel = UILabel.formatedLabel(size: 10, text: "", type: .bold, textAlignment: .left)
        entryFeeLabel.baselineAdjustment = .alignCenters
        entryFeeLabel.backgroundColor = .clear
        entryFeeLabel.numberOfLines = 1
        entryFeeLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(entryFeeLabel)
        entryFeeLabel.activeSelfConstrains([.height(25)])
        entryFeeLabel.activeConstraints(to: ticketIcon, directions: [.leading(.trailing, 4), .centerY])

        tournamentTitle = UILabel.formatedLabel(size: 16, type: .bold, textAlignment: .left)
        contentView.addSubview(tournamentTitle)
        tournamentTitle.activeConstraints(to: thumbnailView, directions: [.top(.bottom, 14), .leading(.leading)] )
        tournamentTitle.activeSelfConstrains([.height(22)])

        playButton = UIImageView(image: UIImage(named: "thumbnail_play_button"))
        contentView.addSubview(playButton)
        playButton.activeConstraints(to: thumbnailView, directions: [.trailing(.trailing), .top(.bottom, 20)])
        playButton.activeSelfConstrains([.height(40), .width(40)])
        tournamentTitle.activeConstraints(to: playButton, directions: [.trailing(.leading, 10)])
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(playAction))
        playButton.addGestureRecognizer(tapGesture)
      
        keywordLabels = Self.KeywordColors.map { textColor in
            let label = UILabel.formatedLabel(size: 12, text: "", type: .regular, textAlignment: .center)
            label.backgroundColor = .keywordBlackBg
            label.textColor = textColor
            label.layer.cornerRadius = 11
            label.clipsToBounds = true
            return label
        }
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        keywordStackView = UIStackView(arrangedSubviews: keywordLabels + [spacerView])
        keywordStackView.axis = .horizontal
        keywordStackView.alignment = .center
        keywordStackView.distribution = .fill
        contentView.addSubview(keywordStackView)
        keywordStackView.activeConstraints(to: tournamentTitle, directions: [.leading(), .trailing(), .top(.bottom, 4)])
        keywordStackView.activeSelfConstrains([.height(22)])

        tournamentIntro = UILabel.formatedLabel(size: 14)
        tournamentIntro.numberOfLines = 2
        tournamentIntro.textAlignment = .left
        contentView.addSubview(tournamentIntro)
        tournamentIntro.activeSelfConstrains([.height(49), .width(253)])
        tournamentIntro.activeConstraints(directions: [.leading(.leading, 20), .centerX])
        tournamentIntro.activeConstraints(to: thumbnailView, directions: [.top(.bottom, 78)])

        playerCountIcon = UIImageView.fromImage(name: "players_count_icon")
        contentView.addSubview(playerCountIcon)
        playerCountIcon.activeConstraints(to: tournamentIntro, directions: [.leading(), .top(.bottom, 4)])
        playerCountIcon.activeSelfConstrains([.width(80), .height(32)])

        playerCountLabel = UILabel.formatedLabel(size: 10, text: "", type: .medium, textAlignment: .center)
        playerCountLabel.adjustsFontSizeToFitWidth = true
        contentView.addSubview(playerCountLabel)
        playerCountLabel.activeConstraints(to: playerCountIcon, directions: [.centerY, .trailing(.trailing, -2), .top(), .bottom()])
        playerCountLabel.activeSelfConstrains([.width(28)])
        playerCountIcon.isHidden = true
        playerCountLabel.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        configure(with: ViewData(thumbnail: UIImage(),
                                 tournamentTitle: "",
                                 tournamentIntro: "",
                                 keywords: [],
                                 entryFee: 0,
                                 participantNumber: nil,
                                 joinPlayersCount: nil,
                                 isPVP: false,
                                 koko: 0))
    }

    func configure(with viewData: ViewData) {
        thumbnailView.image = viewData.thumbnail
        tournamentTitle.text = viewData.tournamentTitle
        tournamentIntro.text = viewData.tournamentIntro
        viewData.participantNumber.flatMap {
            playerCountLabel.text = "\(viewData.joinPlayersCount ?? 0)/\($0)"
        }

        let joinText = "home_tnm_join_tag".localized
        entryFeeLabel.text = "\(viewData.entryFee)\(joinText)"

        playerCountIcon.isHidden = viewData.isPVP
        playerCountLabel.isHidden = viewData.isPVP
        koko.text = String(viewData.koko)

        keywordLabels.enumerated().forEach { index, label in
            if let keyword = viewData.keywords[safe: index] {
                // FIXME: should override drawText in UILabel's subclass to adjust spacing.
                label.text = " \(keyword) 　" // add spacing for cornerRadius
            } else {
                label.text = nil
            }
        }
        keywordStackView.setNeedsLayout()
        keywordStackView.layoutIfNeeded()
    }

    @objc func playAction() {
        eventHandler?.HandleEvent(.playTournament)
    }
}
