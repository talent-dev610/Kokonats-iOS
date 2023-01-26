////  TournamentListCell.swift
//  kokonats
//
//  Created by sean on 2021/09/24.
//  
//

import Foundation
import UIKit

class TournamentListCell: UITableViewCell {
    private var _containerView: ListBlockContainerView?
    var eventHandler: EventHandler? {
        didSet {
            containerView?.eventHandler = eventHandler
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        if let view = UIView.loadNib(from: "ListBlockContainerView") as? ListBlockContainerView {
            _containerView = view
            contentView.addSubview(view)
            view.clipsToBounds = true
            view.activeConstraints(directions: [.top(.top, 10), .leading(), .trailing(), .bottom()])
            view.title.font = UIFont.getKokoFont(type: .bold, size: 34)
            view.title.text = NSLocalizedString("home_tnm_title", comment: "")
        }
        contentView.backgroundColor = .kokoBgColor
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class GameListCell: UITableViewCell {
    private var _containerView: GameListContainerView!
    var eventHandler: EventHandler? {
        didSet {
            _containerView.eventHandler = eventHandler
        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .kokoBgColor
        _containerView = GameListContainerView()
        contentView.addSubview(_containerView)
        _containerView.activeConstraints(directions: [.top(.top, 20), .leading(), .trailing(), .bottom()])
        _containerView.clipsToBounds = true
        selectionStyle = .none
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateGameList(_ list: [GameDetail]) {
        _containerView.updateGameList(list)
    }
}

class LogoCell: UITableViewCell {
    private var energyLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .kokoBgColor
        let logoView = UIImageView(image: UIImage(named: "new_k_koko_log"))
        logoView.contentMode = .scaleAspectFill
        contentView.addSubview(logoView)
        logoView.activeConstraints(to: contentView, directions: [.leading(.leading, 24), .centerY])
        logoView.heightAnchor.constraint(equalToConstant: 49).isActive = true
        logoView.widthAnchor.constraint(equalToConstant: 148).isActive = true

        let energyBg = UIView()
        contentView.addSubview(energyBg)
        energyBg.activeSelfConstrains([.height(30)])
        energyBg.clipsToBounds = true
        energyBg.layer.cornerRadius = 10
        energyBg.backgroundColor = .kokoLightYellow
        selectionStyle = .none

        let tapGR = UITapGestureRecognizer(target: self, action: #selector(addEnergyAction))
        let addEnergyView = UIImageView(image: UIImage(named: "add_energy_icon"))
        addEnergyView.addGestureRecognizer(tapGR)
        contentView.addSubview(addEnergyView)
        addEnergyView.isUserInteractionEnabled = true
        addEnergyView.activeConstraints(directions: [.trailing(.trailing, -22), .centerY])
        addEnergyView.activeSelfConstrains([.height(24), .width(24)])
        energyBg.activeConstraints(to: addEnergyView, directions: [.trailing(.trailing, 2), .centerY])

        energyLabel = UILabel.formatedLabel(size: 14, text: "", type: .regular, textAlignment: .left)
        contentView.addSubview(energyLabel)
        energyLabel.textColor = .white
        energyLabel.activeConstraints(to: addEnergyView, directions: [.trailing(.leading, -22)])
        energyLabel.activeConstraints(to: energyBg, directions: [.top(.top, 1)])
        energyLabel.baselineAdjustment = .alignCenters
        energyLabel.adjustsFontSizeToFitWidth = true
        energyLabel.activeSelfConstrains([.height(25)])

        let energyIcon = UIImageView.fromImage(name: "energy_icon")
        contentView.addSubview(energyIcon)
        energyIcon.activeSelfConstrains([.width(9), .height(16)])
        energyIcon.activeConstraints(to: energyLabel, directions: [.trailing(.leading, -3)])
        energyIcon.activeConstraints(to: energyBg, directions: [.top(.top, 6)])
        energyIcon.leadingAnchor.constraint(greaterThanOrEqualTo: logoView.trailing, constant: 30).isActive = true
        energyBg.activeConstraints(to: energyIcon, directions: [.leading(.leading, -5)])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func updateEnergy(energy: String) {
        energyLabel.text = energy
    }

    @objc func addEnergyAction() {
        NotificationCenter.default.post(name: .showEnergyStore, object: nil)
    }
}

class BannerCell: UITableViewCell {

    private var bannerLabel: UILabel!
    private var timer: Timer?
    private var bannerLabelList = [UILabel]()
    private var currentBannerIndex: Int = 0
    private var totalCount: Int = 5
    private var initialCGRect = CGRect(x: screenSize.width / 2, y: 24, width: 250, height: 20)

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        contentView.clipsToBounds = true

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: 66)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [UIColor.bannerBlue.cgColor, UIColor.bannerPurple.cgColor]
        contentView.layer.insertSublayer(gradientLayer, at: 0)

        buildAnimationList()

        let overlayPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: screenSize.width, height: 66))
        overlayPath.usesEvenOddFillRule = true

        let squarePath = UIBezierPath(roundedRect: CGRect(x: 24, y: 18, width: screenSize.width - 48, height: 33), cornerRadius: 10)
        overlayPath.append(squarePath)

        let layer = CAShapeLayer()
        layer.fillRule = .evenOdd
        layer.path = overlayPath.cgPath
        layer.fillColor = UIColor.kokoBgColor.cgColor
        contentView.layer.addSublayer(layer)

        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.2) {
            self.fireAnimation(isFirst: true)
        }
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 2) { [weak self] in
          self?.fireAnimation()
          self?.timer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { _ in
              self?.fireAnimation()
          }
        }
    }

    private func fireAnimation(isFirst: Bool = false) {
        let nextLabel: UILabel = {
            if self.currentBannerIndex < self.totalCount-1 {
                self.currentBannerIndex += 1
            } else {
                self.currentBannerIndex = 0
            }
            return self.bannerLabelList[self.currentBannerIndex]
        }()

        DispatchQueue.main.async {
            nextLabel.attributedText = self.getAttributedText()
            if isFirst {
              nextLabel.frame.origin.x = 50
              UIView.animate(withDuration: 7.5, delay: 0, options: [.curveLinear], animations: {
                  nextLabel.frame.origin.x = -220
              }, completion: { _ in
              })
            } else {
                nextLabel.frame.origin.x = screenSize.width
                UIView.animate(withDuration: 15, delay: 0, options: [.curveLinear], animations: {
                    nextLabel.frame.origin.x = -220
                }, completion: { _ in
                })
            }
        }
    }

    private func buildAnimationList() {
        for _ in 0..<totalCount {
            bannerLabel = UILabel()
            bannerLabel.backgroundColor = .clear
            bannerLabel.adjustsFontSizeToFitWidth = true
            contentView.addSubview(bannerLabel)
            bannerLabel.frame =  initialCGRect
            bannerLabelList.append(bannerLabel)
        }
    }

    private func getAttributedText() -> NSAttributedString {
        let userName = AppData.shared.getWinnerUserName()
        let regularAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.white,
            .font : UIFont.getKokoFont(type: .regular, size: 10)
        ]
        let string1 = NSAttributedString(string: "home_banner_congra_word".localized, attributes: regularAttributes)

        let nameAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.white,
            .font : UIFont.getKokoFont(type: .black, size: 10)
        ]

        let string2 = NSAttributedString(string: userName , attributes: nameAttributes)

        let scoreAttributes: [NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.kokoYellow,
            .font : UIFont.getKokoFont(type: .black, size: 10)
        ]

        let string3 = NSAttributedString(string: "home_banner_1000_koko".localized , attributes: scoreAttributes)
        let string4 = NSAttributedString(string: "home_banner_gained_word".localized, attributes: regularAttributes)

        let mutableAttributedString = NSMutableAttributedString()
        mutableAttributedString.append(string1)
        mutableAttributedString.append(string2)
        mutableAttributedString.append(string3)
        mutableAttributedString.append(string4)
        return mutableAttributedString
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

protocol CellConfigurable: UITableViewCell {
    var containerView: ListBlockContainerView? { get }
    func configure(with type: CollectionDataType)
}

extension CellConfigurable {
    func configure(with type: CollectionDataType) {
        if case .tournamentList(let list) = type {
            containerView?.configure(tournamentList: list, location: .homeTournamentViewBlock)
        }
    }
}

extension TournamentListCell: CellConfigurable {
    var containerView: ListBlockContainerView? {
        return _containerView
    }
}

extension GameListCell: CellConfigurable {
    var containerView: ListBlockContainerView? {
        return nil
    }
}

var screenSize: CGSize {
    return UIScreen.main.bounds.size
}
