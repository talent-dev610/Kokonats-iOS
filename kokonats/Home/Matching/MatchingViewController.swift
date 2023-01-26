//
//  MatchingViewController.swift
//  kokonats
//
//  Created by JR20233 on 2021/10/05.
//

import UIKit

class MatchingViewController: UIViewController {
    static private let AnimationSec: Int = 1
    static private let AnimationCycle: Int = 3
    
    private let titleView = UIView()
    private var matchingLabel: UILabel!
    private var animationLabel: UILabel!
    private var vsLabel: UILabel!
    private let opponentCard = MatchingUserCard()
    private let ownSideCard = MatchingUserCard()
    private var currentUserName = ""
    private var rivalUserName = ""
    private var timerForAnimation: Timer?
    private let dotChar = "matching_dot_char".localized
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopAnimation()
    }

    private func setupView() {
        view.backgroundColor = .kokoBgColor
        titleView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(titleView)
        matchingLabel = UILabel.formatedLabel(size: 34, text: "matching_title".localized, type: .bold, textAlignment: .right)
        matchingLabel.translatesAutoresizingMaskIntoConstraints = false
        animationLabel = UILabel.formatedLabel(size: 24, type: .bold, textAlignment: .left)
        animationLabel.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(matchingLabel)
        titleView.addSubview(animationLabel)
        
        let matchingLabelWidth = matchingLabel.sizeThatFits(
            CGSize(width: .greatestFiniteMagnitude,
                   height: matchingLabel.font.lineHeight)).width
        titleView.addConstraints([
            matchingLabel.heightAnchor.constraint(equalTo: titleView.heightAnchor),
            matchingLabel.widthAnchor.constraint(equalToConstant: matchingLabelWidth),
            matchingLabel.centerXAnchor.constraint(equalTo: titleView.centerXAnchor, constant: -34),
            animationLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor, constant: 4),
            animationLabel.leadingAnchor.constraint(equalTo: matchingLabel.trailingAnchor, constant: 4),
            animationLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor)
        ])

        vsLabel = UILabel.formatedLabel(size: 16, text: "Vs.", type: .black, textAlignment: .center)
        vsLabel.translatesAutoresizingMaskIntoConstraints = false
        let stackView = UIStackView(
            arrangedSubviews: [opponentCard, vsLabel, ownSideCard]
        )
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 46
        stackView.addConstraints([
            opponentCard.heightAnchor.constraint(equalTo: ownSideCard.heightAnchor),
            opponentCard.widthAnchor.constraint(equalTo: stackView.widthAnchor),
            ownSideCard.widthAnchor.constraint(equalTo: stackView.widthAnchor),
        ])
        view.addSubview(stackView)

        view.addConstraints([
            titleView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 36),
            titleView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            titleView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            titleView.heightAnchor.constraint(equalToConstant: 50),
            stackView.topAnchor.constraint(equalTo: titleView.bottomAnchor, constant: 36),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            view.trailingAnchor.constraint(equalTo: stackView.trailingAnchor, constant: 60),
            view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: stackView.bottomAnchor, constant: 84)
        ])

        // will be set after matching.
        opponentCard.userName = ""
        opponentCard.image = nil
    }

    func updateCurrentUserName(_ currentUserName: String, icon: String) {
        ownSideCard.userName = currentUserName
        ownSideCard.image = UIImage(named: "avatar_\(icon)")
    }

    func updateRivalUserName(_ userName: String, icon: String) {
        opponentCard.userName = userName
        opponentCard.image = UIImage(named: "avatar_\(icon)")
    }
    
    // MARK: - animation
    private func animate(cycle: Int = 0) {
        if cycle > Self.AnimationCycle {
            animationLabel.text = ""
            return
        }
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(Self.AnimationSec))) { [weak self] in
            guard let char = self?.dotChar else { return }
            self?.animationLabel.text = (0...cycle).map { _ in char }.joined()
            self?.animate(cycle: cycle + 1)
        }
    }
    
    private func startAnimation() {
        let interval = Double(Self.AnimationSec * (Self.AnimationCycle + 1))
        timerForAnimation = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.animate()
        }
        timerForAnimation?.fire()
    }
    
    private func stopAnimation() {
        timerForAnimation?.invalidate()
        timerForAnimation = nil
        animationLabel.text = nil
    }
}
