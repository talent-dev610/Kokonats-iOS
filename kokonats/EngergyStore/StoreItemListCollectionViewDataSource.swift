////  StoreGameItemListCollectionViewDataSource.swift
//  kokonats
//
//  Created by sean on 2022/03/19.
//  
//

import Foundation
import UIKit

final class StoreItemListCollectionViewDataSource: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    var eventHandler: StoreEventHandler?
    var itemList = [GameItem]()
    var purchasedItemIdList = [Int]()
    var blockPurchasing = false

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return itemList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreItemListCollectionViewCell", for: indexPath) as! StoreItemListCollectionViewCell
        let item = itemList[indexPath.row]
        let tapAction = GameItemTapGesture(target: self, action: #selector(purchaseItemAction(sender:)))
        tapAction.item = item
        cell.addGestureRecognizer(tapAction)
        
        if let url = item.pictureUrl {
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

        cell.update(price: item.kokoPrice ?? 0, isPurchased: isPurchased(item.id) )
        return cell
    }

    private func isPurchased(_ gameItemId: Int) -> Bool {
        return purchasedItemIdList.contains(gameItemId)
    }
    
    @objc private func purchaseItemAction(sender: UIGestureRecognizer) {
        sender.view?.clickEffect()

        let item = (sender as? GameItemTapGesture)?.item
        let isPurchased = isPurchased(item!.id)

        if !isPurchased && !blockPurchasing {
            blockPurchasing = true
            eventHandler?.handleEvent(.purchaseGameItem(gameItem: item!))
        }
    }
}

private class GameItemTapGesture: UITapGestureRecognizer {
    var item: GameItem?
}
