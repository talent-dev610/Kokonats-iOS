////  ListContainerView.swift
//  kokonats
//
//  Created by sean on 2021/09/23.
//  
//

import Foundation
import UIKit


//TODO: refactor this to TournamentContainerView
//TODO: replace xib file with swift code.
class ListBlockContainerView: UIView {

    enum Location {
        case gameDetailView(matches: [GameMatch])
        case homeTournamentViewBlock
    }

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var itemCollectionView: UICollectionView!
    @IBOutlet weak var layout: UICollectionViewFlowLayout!
    @IBOutlet weak var heightOfCollectionView: NSLayoutConstraint!
    @IBOutlet weak var tabPlaceHolderView: UIImageView!
    private var imageCaches = [Int: UIImage]()

    var taglistContainerView: TagListContainerView!
    private var tournamentList = [TournamentClassDetail]()
    var location: Location!
    var eventHandler: EventHandler?

    private var dataCount: Int {
        if isPVPselected {
            return selectedMatches.count
        } else {
            return selectedTournamentList.count
        }
    }

    private var selectedTag: String?

    private var selectedTournamentList: [TournamentClassDetail] {
        switch location {
        case .gameDetailView:
            if selectedTag == "practice_tag".localized {
                return tournamentList.filter{ $0.type == 3 }
            } else if selectedTag == "tournament_tag".localized {
                return tournamentList.filter{ $0.type != 3 }
            } else {
                return [TournamentClassDetail]()
            }

        case .homeTournamentViewBlock:
            if let tag = selectedTag {
                return tournamentList.filter { $0.tags.contains(tag) }
            } else {
                return tournamentList
            }

        case .none:
            return [TournamentClassDetail]()
        }
    }

    private var selectedMatches: [GameMatch] {
        if case .gameDetailView(let matches) = location,
           selectedTag == "PVP" {
            return matches
        }
        return [GameMatch]()
    }

    private var isPVPselected: Bool {
        if case .gameDetailView = location,
           selectedTag == "PVP" {
            return true
        }
        return false
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        prepare()
    }

    private func prepare() {
        itemCollectionView.dataSource = self
        itemCollectionView.delegate = self
        itemCollectionView.backgroundColor = .kokoBgColor
        itemCollectionView.register(TournamentListCollectionViewCell.self, forCellWithReuseIdentifier: "TournamentListCollectionViewCell")

        //TODO: (need to refactor this code to remove placeholder view)
        taglistContainerView = TagListContainerView()
        taglistContainerView.delegate = self
        addSubview(taglistContainerView)
        taglistContainerView.activeConstraints(to: tabPlaceHolderView)
        tabPlaceHolderView.isHidden = true

        layout.minimumInteritemSpacing = 14
        layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 10, right: 10)
        itemCollectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 14)
        itemCollectionView.reloadData()
        itemCollectionView.showsHorizontalScrollIndicator = false
    }

    func configure(tournamentList: [TournamentClassDetail], location: Location) {
        self.tournamentList = tournamentList
        self.location = location
        switch location {
        case .gameDetailView:
            heightOfCollectionView.constant = 360
            if getTaglist().count > 0 {
                selectedTag = getTaglist()[0]
            } else {
                selectedTag = nil
            }
            taglistContainerView.updateData(tagList: getTaglist(), needAllTag: false)
        case .homeTournamentViewBlock:
            heightOfCollectionView.constant = 374
            taglistContainerView.updateData(tagList: getTaglist())
        }
        itemCollectionView.reloadData()
    }

    func selectTag(_ tag: String?) {
        selectedTag = tag
        itemCollectionView.reloadData()
    }

    private func getTaglist() -> [String] {
        switch location {
        case .gameDetailView(let matches):
            var tags = [String]()
            tournamentList.first {
                $0.type != 3
            }.flatMap { _ in
                tags.append("tournament_tag".localized)
            }

            if matches.count > 0 {
                tags.append("PVP")
            }

            tournamentList.first {
                $0.type == 3
            }.flatMap { _ in tags.append("practice_tag".localized) }

            return tags.removingDuplicates()
        case .homeTournamentViewBlock:
            let allTags = tournamentList.flatMap({ $0.tags })
            return allTags.removingDuplicates()
        case .none:
            return [String]()
        }
    }

    private func event(at index: Int) -> Event {
        switch location {
        case .gameDetailView(let matches):
            if isPVPselected {
                return .startMatching(matchClassId: matches[index].id)
            } else {
                return .showTournament(tournamentId: selectedTournamentList[index].id)
            }
        case .homeTournamentViewBlock:
            return .showTournament(tournamentId: selectedTournamentList[index].id)
        case .none:
            return .unknown
        }
    }
}

extension ListBlockContainerView: TagSelectionDelegate {
    func tagDidSelected(_ view: UIView, tag: String?) {
        self.selectTag(tag)
    }
}

extension ListBlockContainerView: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        eventHandler?.HandleEvent(event(at: indexPath.row))
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 295, height: 360)
    }
}

extension ListBlockContainerView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataCount
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    private func loadImage(for cell: TournamentListCollectionViewCell, tournament: TournamentClassDetail, row: Int) {
        if let thumbnailUrl = tournament.thumbnail, !thumbnailUrl.isEmpty {
            ImageCacheManager.shared.loadImage(urlString: thumbnailUrl) { [weak self, weak cell] result in
                DispatchQueue.main.async {
                    guard let self = self, let cell = cell else { return }
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            let viewData = self.buildViewData(from: tournament, image: image, playersCount: nil)
                            self.imageCaches[tournament.id] = image
                            cell.configure(with: viewData)
                            self.loadJoinPlayersCount(for: cell, tournamentClass: tournament, image: image)
                        } else {
                            Logger.debug("failed to get image data")
                        }
                    case .failure(let error):
                        Logger.debug("\(error)")
                        break
                    }
                }
            }
        }
    }
    
    private func loadJoinPlayersCount(for cell: TournamentListCollectionViewCell, tournamentClass: TournamentClassDetail, image: UIImage) {
        // if this tournament is playable, server returns tournament detail. if not, server returns error.
        // ref: https://github.com/BiiiiiT-Inc/koko-iOS/issues/69
        // NOTE: 画像と同期処理して cell.configure を一度だけにしたいけど、どちらかの要因で更新されなくなってしまう可能性を排除するため処理を分けた。
        //       ・開催中でないトーナメントの場合にサーバーエラーで joinPlayersCount が取れない
        //       ・画像のキャッシュがある時の分岐処理
        ApiManager.shared.getPlayableTournament(tournamentId: String(tournamentClass.id), idToken: LocalStorageManager.idToken) { [weak self, weak cell] result in
            switch result {
            case .success(let tournament):
                if let viewData = self?.buildViewData(from: tournamentClass, image: image, playersCount: tournament.joinPlayersCount) {
                    cell?.configure(with: viewData)
                }
            case .failure(let error):
                Logger.debug(#function + " /w tcid = \(tournamentClass.id) ERROR: \(error)")
            }
        }
    }

    private func buildViewData(from tournament: TournamentClassDetail, image: UIImage, playersCount: Int?) -> TournamentListCollectionViewCell.ViewData {
        return TournamentListCollectionViewCell.ViewData(thumbnail: image,
                                                         tournamentTitle: tournament.tournamentName ?? "",
                                                         tournamentIntro: tournament.description ?? "",
                                                         keywords: (tournament.keyword ?? "").components(separatedBy: ","),
                                                         entryFee: tournament.entryFee ?? 0,
                                                         participantNumber: tournament.participantNumber,
                                                         joinPlayersCount: playersCount,
                                                         isPVP: false,
                                                         koko: tournament.kokoReward ?? 0)
    }

    private func buildViewData(from match: GameMatch, image: UIImage) -> TournamentListCollectionViewCell.ViewData {
        return TournamentListCollectionViewCell.ViewData(thumbnail: image,
                                                         tournamentTitle: match.matchName ?? "",
                                                         tournamentIntro: match.description ?? "",
                                                         keywords: (match.keyword ?? "").components(separatedBy: ","),
                                                         entryFee: match.entryFee ?? 0,
                                                         participantNumber: 0,
                                                         joinPlayersCount: nil,
                                                         isPVP: true,
                                                         koko: match.winningPayout ?? 0)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TournamentListCollectionViewCell", for: indexPath) as! TournamentListCollectionViewCell

        if isPVPselected {
            let match = selectedMatches[indexPath.row]
            if let image = imageCaches[match.id] {
                let viewData = buildViewData(from: match, image: image)
                cell.configure(with: viewData)
            } else {
                loadImage(for: cell, match: match, row: indexPath.row)
            }
        } else {
            let tournament = selectedTournamentList[indexPath.row]
            if let image = imageCaches[tournament.id] {
                let viewData = buildViewData(from: tournament, image: image, playersCount: nil)
                cell.configure(with: viewData)
                loadJoinPlayersCount(for: cell, tournamentClass: tournament, image: image)
            } else {
                loadImage(for: cell, tournament: tournament, row: indexPath.row)
            }

        }
        return cell
    }

    private func loadImage(for cell: TournamentListCollectionViewCell, match: GameMatch, row: Int) {
        if let thumbnailUrl = match.thumbnail, !thumbnailUrl.isEmpty {
            ImageCacheManager.shared.loadImage(urlString: thumbnailUrl) { [weak self] result in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            let viewData = self.buildViewData(from: match, image: image)
                            self.imageCaches[match.id] = image
                            cell.configure(with: viewData)
                        } else {
                            Logger.debug("failed to get image data")
                        }
                    case .failure(let error):
                        Logger.debug("\(error)")
                        break
                    }
                }
            }
        }
    }
}
