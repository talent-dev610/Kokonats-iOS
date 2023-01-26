////  GameContainerView.swift
//  kokonats
//
//  Created by sean on 2021/12/11.
//  
//

import Foundation
import UIKit

class GameListContainerView: UIView {
    var eventHandler: EventHandler?
    private var gameList = [GameDetail]()
    var gameListCollectionView: UICollectionView!
    private var layout: UICollectionViewFlowLayout?
    var tagListContainerView: TagListContainerView!

    private var imageCaches = [Int: UIImage]()

    var selectedTag: String?

    private var tagList: [String] {
        return AppData.shared.gameTagList ?? [String]()
    }

    var selectedList: [GameDetail] {
        if let tag = selectedTag {
            return gameList.filter { $0.category == tag}
        } else {
            return gameList
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepareLayout()
    }

    func prepareLayout()  {
        let titleLabel = UILabel.formatedLabel(size: 34, text: "home_game_title".localized, type: .bold, textAlignment: .left)
        addSubview(titleLabel)
        titleLabel.activeConstraints(directions: [.top(), .leading(.leading, 24)])
        titleLabel.activeSelfConstrains([.height(44)])

        tagListContainerView = TagListContainerView()
        tagListContainerView.updateData(tagList: tagList)
        addSubview(tagListContainerView)
        tagListContainerView.delegate = self
        tagListContainerView.activeConstraints(directions: [.leading(), .trailing()])
        tagListContainerView.activeConstraints(to: titleLabel, directions: [.top(.bottom, 14)])
        tagListContainerView.activeSelfConstrains([.height(38)])

        let gameListLayout = UICollectionViewFlowLayout()
        gameListLayout.scrollDirection = .horizontal
        gameListLayout.itemSize = CGSize(width: 255, height: 150)
        gameListLayout.minimumLineSpacing = 14
        gameListLayout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)

        gameListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: gameListLayout)
        addSubview(gameListCollectionView)
        gameListCollectionView.backgroundColor = .kokoBgColor
        gameListCollectionView.activeConstraints(directions: [.leading(), .trailing(), .bottom()])
        gameListCollectionView.activeConstraints(to: tagListContainerView, directions: [.top(.bottom)])
        gameListCollectionView.register(GameListCollectionViewCell.self, forCellWithReuseIdentifier: "GameListCollectionViewCell")
        gameListCollectionView.delegate = self
        gameListCollectionView.dataSource = self
        gameListCollectionView.contentInset = UIEdgeInsets(top: 0, left: 14, bottom: 0, right: 10)
        gameListCollectionView.showsHorizontalScrollIndicator = false
    }

    func selectedTag(_ tag: String?) {
        selectedTag = tag
        gameListCollectionView.reloadData()
    }

    func updateGameList(_ gameList: [GameDetail]) {
        self.gameList = gameList
        gameListCollectionView.reloadData()
        tagListContainerView.updateData(tagList: tagList)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension GameListContainerView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 24
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 14
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard selectedList.count > indexPath.row else {
            Logger.debug("indexPath.section:\(indexPath.row) is wrong.")
            return
        }
        eventHandler?.HandleEvent(.showGameDetail(gameId: selectedList[indexPath.row].id))
    }
}

extension GameListContainerView: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        selectedList.count
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameListCollectionViewCell", for: indexPath) as! GameListCollectionViewCell
        let gameDetail = selectedList[indexPath.row]
        if let url = gameDetail.coverImageUrl, !url.isEmpty {
            if let image = imageCaches[gameDetail.id] {
                cell.configure(with: image, index: indexPath.row, imageName: url)
            } else {
                loadImage(for: cell, url: url, row: indexPath.row)
            }
        } else {
            Logger.debug("loadImage failed")
        }
        return cell
    }

    private func loadImage(for cell: GameListCollectionViewCell, url: String, row: Int) {
        ImageCacheManager.shared.loadImage(urlString: url) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    if let image = UIImage(data: data), let self = self {
                        self.imageCaches[self.selectedList[row].id] = image
                        cell.configure(with: image, index: row, imageName: "imageName")
                    } else {
                        Logger.debug("loadImage failed")
                    }
                case .failure(let error):
                    Logger.debug("failed to load image\(error)")
                }
            }
        }
    }
}

extension GameListContainerView: TagSelectionDelegate {
    func tagDidSelected(_ view: UIView, tag: String?) {
        self.selectedTag(tag)
    }
}
