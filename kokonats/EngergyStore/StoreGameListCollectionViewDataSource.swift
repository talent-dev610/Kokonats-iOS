////  GameListCollectionViewDataSource.swift
//  kokonats
//
//  Created by sean on 2022/03/16.
//  
//

import Foundation
import UIKit

final class StoreGameListCollectionViewDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    var purchasedItems = [PurchasedGameItem]()
    var gameItems = [GameItem]()
    var gameList = [GameDetail]()
    var previousSelectedCell: StoreGameListCollectionViewCell?
    var selectedGameId: Int?

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return gameList.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! StoreGameListCollectionViewCell
        previousSelectedCell?.updateStatus(isSelected: false)
        cell.updateStatus(isSelected: true)
        previousSelectedCell = cell
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreGameListCollectionViewCell", for: indexPath) as! StoreGameListCollectionViewCell
        if let url = gameList[indexPath.row].iconUrl {
            ImageCacheManager.shared.loadImage(urlString: url) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            cell.updateIcon(with: image)
                        } else {
                            Logger.debug("failed to get image data")
                        }
                    case .failure(let error):
                        Logger.debug("\(error)")
                    }
                }
            }
        }

        cell.updateStatus(isSelected: selectedGameId == gameList[indexPath.row].id)
        return cell
    }

}
