////  GameDetailViewController.swift
//  kokonats
//
//  Created by sean on 2021/09/23.
//  
//

import Foundation
import UIKit

struct GameDetailData {
    let gameData: GameDetail
    let tournamentList: [TournamentClassDetail] // for tournament and practice tab
    let matchList: [GameMatch] // for pvp tab
}

final class GameDetailViewController: UIViewController {
    var gameDetailData: GameDetailData!
    private var _resultView: ResultView?
    private var listContainerView: ListBlockContainerView!
    private var scrollView = UIScrollView()
    private let matchingVC = MatchingViewController()

    private var thumbnailView: UIImageView!
    private let screenSize: CGRect = UIScreen.main.bounds
    private var shareButton: UIImageView!

    var eventHandler: EventHandler?
    private var matchPlayId: Int?
    private var userInfo: UserInfo?
    private var startedmatchClassId: Int?
    private var matchRivalUsername: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareLayout()
        view.layoutIfNeeded()
    }

    private func prepareLayout() {
        view.backgroundColor = .kokoBgColor
        view.addSubview(scrollView)
        scrollView.activeConstraints(to: view.safeAreaLayoutGuide, anchorDirections: [.top(), .leading(), .bottom(), .trailing()])
        scrollView.showsVerticalScrollIndicator = false

        let containerView = UIView()
        scrollView.addSubview(containerView)
        containerView.activeConstraints(to: scrollView.contentLayoutGuide,  anchorDirections: [.top(), .leading(), .bottom(), .trailing()])
        containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true

        thumbnailView = UIImageView()
        thumbnailView.contentMode = .scaleAspectFit
        thumbnailView.backgroundColor = .kokoBgColor
        thumbnailView.layer.cornerRadius = 10
        thumbnailView.clipsToBounds = true
        containerView.addSubview(thumbnailView)
        thumbnailView.activeConstraints(directions: [.leading(.leading, 24), .top(.top, 70), .centerX])
        let sideLength = screenSize.width - 24*2
        thumbnailView.activeSelfConstrains([.height(sideLength)])
        thumbnailView.layer.cornerRadius = 10
        updateThumbnail(url: gameDetailData.gameData.screenshot ?? "")

        let titleLabel = UILabel.formatedLabel(size: 21,
                                               text: gameDetailData.gameData.name,
                                               type: .bold,
                                               textAlignment: .left)
        containerView.addSubview(titleLabel)
        titleLabel.activeConstraints(to: thumbnailView, directions: [.leading(.leading, 20), .bottom(.bottom, -8), .trailing(.trailing, -20)])
        titleLabel.activeSelfConstrains([.height(28)])
        
        shareButton = UIImageView()
        containerView.addSubview(shareButton)
        shareButton.image = UIImage(named: "share_button")
        shareButton.isUserInteractionEnabled = true
        shareButton.activeSelfConstrains([.width(40), .height(40)])
        shareButton.activeConstraints(to: thumbnailView, directions: [.trailing(.trailing, -10), .top(.top, 10)])
        let shareTap = UITapGestureRecognizer(target: self, action: #selector(shareTwitter(_:)))
        shareButton.addGestureRecognizer(shareTap)
        
        let sponsorView = UIImageView()
        containerView.addSubview(sponsorView)
        sponsorView.image = UIImage(named: "sponsor_bg_narrow.png")?.aspectFittedToWidth(sideLength)
        sponsorView.contentMode = .scaleAspectFit
        sponsorView.activeConstraints(to: thumbnailView, directions: [.leading(.leading, 0), .top(.bottom, 25)])
        let tapSponsor = UITapGestureRecognizer(target: self, action: #selector(self.tapSponsor))
        sponsorView.addGestureRecognizer(tapSponsor)
        sponsorView.isUserInteractionEnabled = true
        
        let sponsorLabel = PaddingLabel()
        sponsorLabel.backgroundColor = .white
        sponsorLabel.textColor = .black
        sponsorLabel.text = "Supported By CLOUD7"
        containerView.addSubview(sponsorLabel)
        sponsorLabel.activeConstraints(to: sponsorView, directions: [.centerX, .centerY])
        sponsorLabel.padding = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 20)
        
        let gameIntroLabel = UILabel.formatedLabel(size: 14,
                                                   text: gameDetailData.gameData.introduction,
                                                   type: .regular,
                                                   textAlignment: .left)
        gameIntroLabel.numberOfLines = 0

        containerView.addSubview(gameIntroLabel)
        gameIntroLabel.activeConstraints(directions: [.leading(.leading, 24), .centerX])
        gameIntroLabel.activeConstraints(to: sponsorView, directions: [.top(.bottom, 20)])

        listContainerView = (UIView.loadNib(from: "ListBlockContainerView") as! ListBlockContainerView)
        listContainerView.eventHandler = self

        listContainerView.configure(tournamentList: gameDetailData.tournamentList,
                                    location: .gameDetailView(matches: gameDetailData.matchList))

        containerView.insertSubview(listContainerView, belowSubview: gameIntroLabel)
        listContainerView.title.isHidden = true
        listContainerView.activeConstraints(to: gameIntroLabel, directions: [.top(.bottom, -41)])
        listContainerView.activeConstraints(directions: [.leading(.leading),.trailing(), .bottom()])
        listContainerView.activeSelfConstrains([.height(480)])
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 60, right: 0)

        matchingVC.modalPresentationStyle = .fullScreen
    }
    
    @objc private func shareTwitter(_ sender: Any) {
        shareButton.clickEffect()
        let tweetText = String.localizedStringWithFormat("share_game_detail".localized, gameDetailData.gameData.name!)
        let tweetUrl = "https://game.kokonats.club"
        let post = SharablePost(url: tweetUrl, text: tweetText)
        SocialMediaSharingManager.share(object: post)
    }

    private func updateThumbnail(url: String) {
        if !url.isEmpty {
            ImageCacheManager.shared.loadImage(urlString: url) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            self?.thumbnailView.image = image
                            let layer = CAGradientLayer()
                            layer.cornerRadius = 10
                            if let size = self?.thumbnailView.frame.size {
                                let smallHeight = size.height / 3
                                layer.frame = CGRect(x: 0, y: smallHeight * 1, width: size.width, height: smallHeight * 2)
                                layer.colors = [UIColor.clear, UIColor.black.cgColor]
                                self?.thumbnailView.layer.insertSublayer(layer, at: 0)
                            }
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
            thumbnailView.image = UIImage(named: "game_thumbnail_sample")
        }
    }
    
    @IBAction func tapSponsor() {
        let url = URL(string: "http://www.cloud7.link")!
        UIApplication.shared.open(url)
    }

}

extension GameDetailViewController {
    private func stopPairing(completion: (() -> Void)? = nil) {
        matchingVC.dismiss(animated: true, completion: completion)
    }

    private func startSession(idToken: String, matchClassId: Int) {
        guard AppData.shared.isLoggedIn() else {
            self.dismiss(animated: true) {
                NotificationCenter.default.post(name: .needLogin, object: nil)
            }
            return
        }
        ApiManager.shared.startSession(idToken: idToken, matchClassId: matchClassId) { [weak self] reuslt in
            guard let self = self else {
                return
            }
            switch reuslt {
            case .success(let sessionId):
                self.startPairing(idToken: idToken,
                                  matchClassId: matchClassId,
                                  gameId: self.gameDetailData.gameData.id,
                                  sessionId: sessionId,
                                  retry: 60)
            case .failure(let error):
                self.stopPairing()
                Logger.debug("startPairing: error \(error.localizedDescription)")
                break
            }
        }
    }

    //TODO: remove alert
    private func startPairing(idToken: String, matchClassId: Int, gameId: Int, sessionId: String, retry: Int) {
        guard retry > 0 else {
            stopPairing() {}
            return
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + 1) {
            Logger.debug("matchClassId: \(matchClassId), sessionId: \(sessionId)")
            FirestoreManager.shared.getDocument(collectionName: "dev-matchingSessions",
                                                documentId: sessionId) { [weak self] document in
                guard let data = document?.data(),
                      let state = data["state"] as? Int else {
                          self?.stopPairing() {
                              self?.showAlertDialog(title: "stopPairing", message: "failed to get state of matching session", textOk: "OK")
                          }
                          return
                      }

                switch state {
                // pairing
                case 0, 1:
                    self?.startPairing(idToken: idToken, matchClassId: matchClassId, gameId: gameId, sessionId: sessionId, retry: retry - 1)
                //paired
                case 2:
                    guard let matchPlayId = data["matchPlayId"] as? Int else {
                        self?.stopPairing() {
                            self?.showAlertDialog(title: "stopPairing", message: "failed to get playid", textOk: "OK")
                        }
                        return
                    }

                    if let users = data["matchingUsers"] as? Array<[String: String]> {
                        let picture = String(users[0]["picture"] ?? "5")
                        self?.matchRivalUsername = users[0]["userName"]
                        self?.matchingVC.updateRivalUserName(users[0]["userName"] ?? "", icon: picture)
                    }
                    self?.matchPlayId = matchPlayId
                    ApiManager.shared.getGameAuth(gameId: gameId) { [weak self] result in
                        DispatchQueue.main.async {
                            let duration: Int = self?.gameDetailData.matchList.first(where: { $0.id == matchClassId })?.durationSecond ?? 0
                            if case .success(let token) = result {
                                self?.startPlay(gameAuth: token, playId: String(matchPlayId), duration: duration)
                            } else {
                                self?.stopPairing()
                                Logger.debug("failed to get game auth")
                            }
                        }
                    }
                default:
                    self?.stopPairing() {
                        self?.showAlertDialog(title: "stopPairing", message: "state is wrong: \(state)", textOk: "OK")
                    }
                    break
                }
            }
        }
    }

    private func startPlay(gameAuth: String, playId: String, duration: Int) {
        guard let url = gameDetailData.gameData.cdnUrl else {
            return
        }
        self.matchingVC.dismiss(animated: true) {
            let playgroundVC = PlaygroundViewController()
            playgroundVC.requestInfo = RequestInfo(gameAuth: gameAuth,
                                                   playId: playId,
                                                   playType: .match,
                                                   gameUrl: url,
                                                   duration: duration)
            playgroundVC.modalPresentationStyle = .fullScreen
            playgroundVC.modalTransitionStyle = .crossDissolve
            playgroundVC.resultHandler = self
            self.present(playgroundVC, animated: false, completion: nil)
        }
    }
}

extension GameDetailViewController: EventHandler {
    func HandleEvent(_ event: Event) {
        switch event {
        case .showTournament(let tournamentId):
            guard let tournamentVC = UIStoryboard.buildVC(from: "TournamentDetail") as? TournamentDetailViewController,
                let tournamentDetail = gameDetailData.tournamentList.first(where: { $0.id == tournamentId }) else {
                return
            }

            tournamentVC.playable = PlayableInfo(tournamentClass: tournamentDetail, gameDetail: gameDetailData.gameData)
            present(tournamentVC, animated: true, completion: nil)
        case .startMatching(let matchClassId):
            guard AppData.shared.isLoggedIn() else {
                self.dismiss(animated: true) {
                    NotificationCenter.default.post(name: .needLogin, object: nil)
                }
                return
            }

            self.showConfirmDialog(type: .question, title: "matching_message_title".localized, message: "", textOk: "matching_message_go".localized, textCancel: "matching_message_cancel".localized, onOk: { [weak self] in
                self?.startedmatchClassId = matchClassId
                self?.startSession(idToken: LocalStorageManager.idToken, matchClassId: matchClassId)
                AppData.shared.getCurrentUser { [weak self] userInfo in
                    self?.userInfo = userInfo
                    DispatchQueue.main.async {
                        if let self = self,
                           let userInfo = userInfo {
                            self.matchingVC.updateCurrentUserName(userInfo.userName ?? "", icon: userInfo.picture ?? "5")
                            self.show(self.matchingVC, sender: self)
                        }
                    }
                }
            }, onCancel: nil)

        default:
            break
        }
    }
}

enum ResultEvent {
    case gameResult
    case playAgain
    case backHome

}
protocol GameResultHandler {
    func handleEvent(_ event: ResultEvent)
}

extension GameDetailViewController: GameResultHandler {
    func handleEvent(_ event: ResultEvent) {
        switch event {
        case .gameResult:
            guard let matchPlayId = matchPlayId, let userInfo = userInfo else {
                return
            }

            if _resultView != nil {
                _resultView?.removeFromSuperview()
                _resultView = nil
            }

            ApiManager.shared.getMatchResult(idToken: LocalStorageManager.idToken, matchPlayId: matchPlayId) { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        let resultView = ResultView()
                        self?._resultView = resultView
                        resultView.resultHandler = self
                        self?.view.addSubview(resultView)
                        resultView.activeConstraints()
                        resultView.updateResult(type: .match(data), currentUserInfo: userInfo, playableInfo: nil, gameDetailDataInfo: self?.gameDetailData, matchRivalName: self?.matchRivalUsername)
                    case .failure(let error):
                        Logger.debug(error.localizedDescription)
                        break
                    }
                }
            }

        case .backHome:
            _resultView?.removeFromSuperview()
            _resultView = nil
        case .playAgain:
            _resultView?.removeFromSuperview()
            _resultView = nil
            guard let startedmatchClassId = startedmatchClassId else {
                return
            }
            self.HandleEvent(.startMatching(matchClassId: startedmatchClassId))
        }
    }
}
