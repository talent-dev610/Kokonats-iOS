////  ResultView.swift
//  kokonats
//
//  Created by sean on 2021/11/27.
//  
//

import Foundation
import UIKit

class ResultView: UIView {

    enum GameResultType {
        case touranment([TournamentPlay])
        case match(MatchResult)

        var count: Int {
            switch self {
            case .touranment(let ranking):
                return ranking.count
            case .match(let result):
                return result.players.count
            }
        }

        func element(at index: Int) -> cellData {
            switch self {
            case .touranment(let rankings):
                let ranking = rankings[index]
                return cellData(userName: ranking.userName ?? "", score: ranking.score ?? 0)
            case .match(let result):
                return cellData(userName: result.players[index].username, score: result.players[index].totalScore)
            }
        }

        func score(of userInfo: UserInfo?) -> Int {
            switch self {
            case .touranment(let rankings):
                // TODO: need to compare subscriber
                let tournament = rankings.first { $0.userName == userInfo?.userName }
                return tournament?.score ?? 0
            case .match(let result):
                let player = result.players.first { userInfo?.subscriber == $0.subscriber }
                return player?.totalScore ?? 0
            }
        }
    }

    struct cellData {
        let userName: String
        let score: Int
    }

    var resultHandler: GameResultHandler?
    private var _rankingTableView: UITableView?
    private var resultTitleLabel: UILabel!
    private var gameResultType: GameResultType?
    private var playable: PlayableInfo?
    private var gameDetailData: GameDetailData?
    private var matchRivalUsername: String?
    private var userInfo: UserInfo?
    private var shareButton: UIImageView!

    @objc func backHome(_ sender: Any) {
        resultHandler?.handleEvent(.backHome)
    }

    @objc func playAgain(_ sender: Any) {
        resultHandler?.handleEvent(.playAgain)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func isCurrentUser(at index: Int) -> Bool {
        guard let gameResultType = gameResultType,
                gameResultType.count > index else {
            return false
        }
        switch gameResultType {
        case .touranment(let rankings):
            return rankings[index].userName == userInfo?.userName
        case .match(let result):
            return result.players[index].subscriber == userInfo?.subscriber
        }
    }

    func updateResult(type: GameResultType, currentUserInfo: UserInfo, playableInfo: PlayableInfo?, gameDetailDataInfo: GameDetailData?, matchRivalName: String?) {
        self.gameResultType = type
        self.userInfo = currentUserInfo
        self.playable = playableInfo
        self.gameDetailData = gameDetailDataInfo
        self.matchRivalUsername = matchRivalName
        _rankingTableView?.reloadData()
        switch type {
        case .match(let matchResult):
            switch matchResult.result {
            case "W":
                resultTitleLabel.textColor = .kokoYellow
                resultTitleLabel.text = "result_view_result_win".localized
            case "L":
                resultTitleLabel.textColor = .lightWhiteFontColor
                resultTitleLabel.text = "result_view_result_lost".localized
            case "D":
                resultTitleLabel.textColor = .lightWhiteFontColor
                resultTitleLabel.text = "result_view_result_draw".localized
            default:
                resultTitleLabel.textColor = .lightWhiteFontColor
                resultTitleLabel.text = "result_view_result_playing".localized
            }

        case .touranment(let tournamentList):
            if let myResult = tournamentList.enumerated().first(where: {
                $0.1.userName == userInfo?.userName
            }) {
                resultTitleLabel.text = "\(myResult.offset + 1)"
            }

        }
    }

    private func prepareLayout() {
        backgroundColor = .kokoBgColor
        let titleLabel = UILabel.formatedLabel(size: 34, text: "result_ranking".localized, type: .bold, textAlignment: .left)
        addSubview(titleLabel)
        titleLabel.activeConstraints(directions: [.leading(.leading, 24), .top(.top, 41)])
        titleLabel.activeSelfConstrains([.height(54)])

        resultTitleLabel = UILabel.formatedLabel(size: 48, text: "", type: .bold, textAlignment: .left)
        resultTitleLabel.textColor = .kokoYellow
        resultTitleLabel.adjustsFontSizeToFitWidth = true
        addSubview(resultTitleLabel)
        resultTitleLabel.activeConstraints(to: titleLabel, directions: [.top(.bottom, 10), .leading()])
        resultTitleLabel.activeConstraints(directions: [.trailing(.trailing, -30)])
        resultTitleLabel.activeSelfConstrains([.height(64)])
        
        shareButton = UIImageView()
        addSubview(shareButton)
        shareButton.image = UIImage(named: "share_button")
        shareButton.isUserInteractionEnabled = true
        shareButton.activeSelfConstrains([.width(40), .height(40)])
        shareButton.activeConstraints(directions: [.trailing(.trailing, -24)])
        shareButton.activeConstraints(to: resultTitleLabel, directions: [.top(.top, 10)])
        let shareTap = UITapGestureRecognizer(target: self, action: #selector(shareTwitter(_:)))
        shareButton.addGestureRecognizer(shareTap)

        let tableTitle = UILabel.formatedLabel(size: 14, text: "score_title".localized, type: .regular, textAlignment: .left)
        addSubview(tableTitle)
        tableTitle.activeConstraints(to: resultTitleLabel, directions: [.leading(), .top(.bottom, 13)])
        tableTitle.activeSelfConstrains([.height(19)])

        let rankingTableView = UITableView()
        rankingTableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        rankingTableView.showsHorizontalScrollIndicator = false
        rankingTableView.layer.cornerRadius = 20
        rankingTableView.delegate = self
        rankingTableView.dataSource = self
        addSubview(rankingTableView)
        rankingTableView.activeConstraints(to: tableTitle, directions: [.leading(), .top(.bottom, 8)])
        rankingTableView.activeConstraints(directions: [.centerX])
        rankingTableView.register(RankingTableViewCell.self, forCellReuseIdentifier: "RankingTableViewCell")
        rankingTableView.separatorStyle = .none
        rankingTableView.separatorInset = .zero
        rankingTableView.backgroundColor = .lightBgColor
        _rankingTableView = rankingTableView

        let buttonsContainer = createButtonContainer()
        rankingTableView.activeConstraints(to: buttonsContainer, directions: [.bottom(.top, -30)])
    }

    private func createButtonContainer() -> UIStackView {
        let buttonsContainer = UIStackView()
        buttonsContainer.axis = .horizontal
        buttonsContainer.alignment = .center
        buttonsContainer.spacing = 24
        addSubview(buttonsContainer)

        let backHomeButton = UIImageView(image: UIImage(named: "back_home"))
        let backHomeLabel = UILabel.formatedLabel(size: 14, text: "back_home".localized, type: .black, textAlignment: .center)
        backHomeLabel.adjustsFontSizeToFitWidth = true
        backHomeButton.addSubview(backHomeLabel)
        backHomeLabel.activeConstraints()
        let backHomeTapGR = UITapGestureRecognizer(target: self, action: #selector(backHome(_:)))
        backHomeButton.isUserInteractionEnabled = true
        backHomeButton.addGestureRecognizer(backHomeTapGR)
        buttonsContainer.addArrangedSubview(backHomeButton)
        backHomeButton.activeSelfConstrains([.width(135), .height(48)])

        let playAgainButton = UIImageView(image: UIImage(named: "play_again"))
        let playAgainTapGR = UITapGestureRecognizer(target: self, action: #selector(playAgain(_:)))
        let playAgainLabel = UILabel.formatedLabel(size: 14, text: "play_again".localized, type: .black, textAlignment: .center)
        playAgainButton.addSubview(playAgainLabel)
        playAgainLabel.activeConstraints()
        playAgainButton.isUserInteractionEnabled = true
        playAgainButton.addGestureRecognizer(playAgainTapGR)
        buttonsContainer.addArrangedSubview(playAgainButton)
        playAgainButton.activeSelfConstrains([.width(135), .height(48)])

        buttonsContainer.activeConstraints(directions: [.centerX, .bottom(.bottom, -30)])
        buttonsContainer.activeSelfConstrains([.height(48)])
        return buttonsContainer
    }
    
    @objc private func shareTwitter(_ sender: Any) {
        shareButton.clickEffect()
        var tweetText = ""
        switch self.gameResultType {
        case .match(let matchResult):
            switch matchResult.result {
            case "W":
                tweetText = String.localizedStringWithFormat("share_result_match_win".localized, (self.gameDetailData?.gameData.name)!, self.matchRivalUsername!)
            case "L":
                tweetText = String.localizedStringWithFormat("share_result_match_lose".localized, (self.gameDetailData?.gameData.name)!, self.matchRivalUsername!)
            case "D":
                tweetText = String.localizedStringWithFormat("share_result_match_draw".localized, (self.gameDetailData?.gameData.name)!, self.matchRivalUsername!)
            default:
                tweetText = String.localizedStringWithFormat("share_result_match_draw".localized, (self.gameDetailData?.gameData.name)!, self.matchRivalUsername!)
            }

        case .touranment(let tournamentList):
            if let myResult = tournamentList.enumerated().first(where: {
                $0.1.userName == userInfo?.userName
            }) {
                let rank = myResult.offset + 1
                switch rank {
                case 1:
                    tweetText = String.localizedStringWithFormat("share_result_tournament_1".localized, rank, (self.playable?.gameDetail?.name)!, (self.playable?.tournament?.tournamentName)!)
                case 2:
                    tweetText = String.localizedStringWithFormat("share_result_tournament_2".localized, rank, (self.playable?.gameDetail?.name)!, (self.playable?.tournament?.tournamentName)!)
                case 3:
                    tweetText = String.localizedStringWithFormat("share_result_tournament_3".localized, rank, (self.playable?.gameDetail?.name)!, (self.playable?.tournament?.tournamentName)!)
                default:
                    tweetText = String.localizedStringWithFormat("share_result_tournament_other".localized, rank, (self.playable?.gameDetail?.name)!, (self.playable?.tournament?.tournamentName)!)
                }
            }
        case .none:
            print(".none")
        }
        let tweetUrl = "https://game.kokonats.club"
        let post = SharablePost(url: tweetUrl, text: tweetText)
        SocialMediaSharingManager.share(object: post)
    }
}

extension ResultView: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return gameResultType?.count ?? 1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spaceView = UIView()
        spaceView.backgroundColor = .clear
        return spaceView
    }

    private func getResultForPlayer(resultOfCurrentUser: String, isCurrentUser: Bool) -> String {
        switch resultOfCurrentUser {
        case "W":
            return isCurrentUser ? "W" : "L"
        case "L":
            return isCurrentUser ? "L" : "W"
        case "D":
            return "D"
        default:
            return ""
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingTableViewCell") as! RankingTableViewCell
        if let data = gameResultType?.element(at: indexPath.section) {
            let isCurrentUser = isCurrentUser(at: indexPath.section)
            let rankingText: String = {
                switch gameResultType {
                case .match(let result):
                    return getResultForPlayer(resultOfCurrentUser: result.result ?? "", isCurrentUser: isCurrentUser)
                case .touranment:
                    let ranking = indexPath.section + 1
                    if ranking < 10 {
                        return "0\(ranking)"
                    } else {
                        return "\(ranking)"
                    }
                default:
                    return ""
                }
            }()

            cell.updateData(ranking: rankingText, score: data.score, name: data.userName, isCurrentUser: isCurrentUser)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 41
    }
}
