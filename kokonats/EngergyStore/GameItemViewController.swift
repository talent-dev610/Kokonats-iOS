//
//  GameItemViewController.swift
//  kokonats
//
//  Created by George on 5/6/22.
//

import UIKit

class GameItemViewController: UIViewController {    
    
    var game: GameDetail!
    private var kokoCount: Int = 0
    private var itemListDataSource = StoreItemListCollectionViewDataSource()
    private var itemListCollectionView: UICollectionView!
    private var comingSoonLabel: UILabel!
    private var kokoBalanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        itemListDataSource.eventHandler = self
        configureLayout()
        fetchKokoBalance()
        fetchGameItems(gameId: game.id)
        fetchPurchasedGameItems()
    }
    
    private func configureLayout() {
        self.view.backgroundColor = .kokoBgColor
        
        let backButton = UIButton()
        view.addSubview(backButton)
        backButton.activeConstraints(to: view, directions: [.leading(.leading, 24), .top(.top, 70)])
        backButton.activeSelfConstrains([.height(50), .width(50)])
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
        
        let title = UILabel.formatedLabel(size: 34, text: "shop_item_title".localized, type: .bold, textAlignment: .left)
        view.addSubview(title)
        title.activeConstraints(to: backButton, directions: [.top(.top, 5), .leading(.trailing, 20)])
        title.activeSelfConstrains([.height(40)])

        let kokoBg = UIView()
        kokoBg.cornerRadius = 20
        kokoBg.backgroundColor = .dollarYellow
        view.addSubview(kokoBg)
        kokoBg.activeSelfConstrains([.width(295), .height(60)])
        kokoBg.activeConstraints(directions: [.centerX])
        kokoBg.activeConstraints(to: title, directions: [.top(.bottom, 24)])

        let kokoIcon = UIImageView(image: UIImage(named: "dollar_icon"))
        view.addSubview(kokoIcon)
        kokoIcon.activeConstraints(to: kokoBg, directions: [.leading(.leading, 20), .centerY])
        kokoIcon.activeSelfConstrains([.height(40), .width(40)])

        kokoBalanceLabel = UILabel.formatedLabel(size: 28, text: "0", type: .bold, textAlignment: .center)
        view.addSubview(kokoBalanceLabel)
        kokoBalanceLabel.activeConstraints(to: kokoBg, directions: [.trailing(.trailing, -20), .centerY])
        kokoBalanceLabel.activeConstraints(to: kokoIcon, directions: [.leading(.trailing, 1)])
        
        let gameView = UIView()
        gameView.cornerRadius = 10
        gameView.backgroundColor = .lightBgColor
        view.addSubview(gameView)
        gameView.activeSelfConstrains([.height(80)])
        gameView.activeConstraints(directions: [.leading(.leading, 24), .trailing(.trailing, -24)])
        gameView.activeConstraints(to: kokoBg, directions: [ .top(.bottom, 37)])
        gameView.shadow(offset: CGSize(width: 0, height: 8), radius: 8, color: UIColor.black.cgColor, opacity: 0.2)

        let iconImage = UIImageView()
        iconImage.backgroundColor = .clear
        gameView.addSubview(iconImage)
        iconImage.activeConstraints(directions: [.leading(.leading, 10), .centerY])
        iconImage.contentMode = .scaleAspectFit
        iconImage.activeSelfConstrains([.width(60), .height(60)])
        let gameIcon = game.iconUrl ?? ""
        if !gameIcon.isEmpty {
            ImageCacheManager.shared.loadImage(urlString: gameIcon) {result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            iconImage.image = image
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
            iconImage.image = UIImage(named: "game_thumbnail_sample")
        }

        let titleLabel = UILabel.formatedLabel(size: 18, text: game.name, type:.medium, textAlignment: .left)
        titleLabel.textColor = .white
        gameView.addSubview(titleLabel)
        titleLabel.activeConstraints(to: iconImage, directions: [.leading(.trailing, 20), .centerY])

        let itemListCVLayout = UICollectionViewFlowLayout()
        itemListCVLayout.scrollDirection = .vertical
        itemListCVLayout.itemSize = CGSize(width: (screenSize.width - 80)/3.0, height: 140)
        itemListCVLayout.minimumLineSpacing = 20

        itemListCollectionView = UICollectionView(frame: .zero, collectionViewLayout: itemListCVLayout)
        view.addSubview(itemListCollectionView)
        itemListCollectionView.register(StoreItemListCollectionViewCell.self, forCellWithReuseIdentifier: "StoreItemListCollectionViewCell")
        itemListCollectionView.delegate = itemListDataSource
        itemListCollectionView.dataSource = itemListDataSource
        itemListCollectionView.activeConstraints(to: gameView, directions: [.top(.bottom, 35)])
        itemListCollectionView.activeConstraints(directions: [.bottom(), .leading(.leading, 24), .centerX])
        itemListCollectionView.backgroundColor = .clear
        itemListCollectionView.activeSelfConstrains([.height(screenSize.height - 320)])
        
        comingSoonLabel = UILabel.formatedLabel(size: 20, text: "COMING SOON", type: .black, textAlignment: .center)
        view.addSubview(comingSoonLabel)
        comingSoonLabel.activeConstraints(to: gameView, directions: [.centerX, .top(.bottom, 40)])
        comingSoonLabel.activeSelfConstrains([.height(22)])
        comingSoonLabel.isHidden = true
    }
    
    private func fetchKokoBalance() {
        ApiManager.shared.getKokoBalance(idToken: LocalStorageManager.idToken) { [weak self] result in
            DispatchQueue.main.async { [self] in
                if case .success(let data) = result {
                    self?.kokoCount = Int(data.confirmed) ?? 0
                    self?.kokoBalanceLabel.text = self?.kokoCount.formatedString()
                }
            }
        }
    }
    
    func fetchGameItems(gameId: Int) {
        ApiManager.shared.getGameItems(idToken: LocalStorageManager.idToken, gameId: String(gameId)) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let itemList):
                    self?.updateItemList(itemList)
                case .failure(let error):
                    Logger.debug("error: \(error.localizedDescription)")
                    break
                }
            }
        }
    }
    
    private func updateItemList(_ itemList: [GameItem]) {
        guard !itemList.isEmpty else {
            itemListCollectionView.isHidden = true
            comingSoonLabel.isHidden = false
            return
        }
        itemListCollectionView.isHidden = false
        comingSoonLabel.isHidden = true
        itemListDataSource.itemList = itemList
        itemListCollectionView.reloadData()
    }
    
    private func fetchPurchasedGameItems() {
        ApiManager.shared.getPurchasedGameItems(idToken: LocalStorageManager.idToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let purchasedItemList):
                    let gameItemIdList = purchasedItemList.compactMap { $0.gameItemId }
                    self.updatePurchasedItemList(gameItemIdList)
                case .failure(let error):
                    Logger.debug("error: \(error.localizedDescription)")
                    break
                }
            }
        }
    }
    
    private func updatePurchasedItemList(_ list: [Int]) {
        itemListDataSource.purchasedItemIdList = list
        itemListCollectionView.reloadData()
        itemListDataSource.blockPurchasing = false
    }
    
    private func presentInsufficientKokoAlert() {
        self.showAlertDialog(title: "shop_403_koko_error_title".localized, message: "shop_403_koko_error_description".localized, textOk: "OK")
    }
    
    private func purchaseItem(gameItemId: Int) {
        ApiManager.shared.exchangeGameItem(idToken: LocalStorageManager.idToken, gameItemId: gameItemId) {[weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    self?.fetchKokoBalance()
                    self?.itemListDataSource.purchasedItemIdList.append(gameItemId)
                    if let list = self?.itemListDataSource.purchasedItemIdList {
                        self?.updatePurchasedItemList(list)
                    }
                default:
                    self?.itemListDataSource.blockPurchasing = false
                    break
                }

            }
        }
    }

    @objc func goBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
}

protocol StoreEventHandler {
    func handleEvent(_ event: StoreClickEvent)
}

enum StoreClickEvent {
    case purchaseGameItem(gameItem: GameItem)
}

extension GameItemViewController: StoreEventHandler {
    func handleEvent(_ event: StoreClickEvent) {
        switch event {
        case .purchaseGameItem(let gameItem):
            guard (gameItem.kokoPrice ?? 0) < kokoCount else {
                self.itemListDataSource.blockPurchasing = false
                presentInsufficientKokoAlert()
                return
            }
            self.showConfirmDialog(type: .question, title: "shop_purchased_confirm_label".localized, message: "", textOk: "purchase_confirm_ok".localized, textCancel: "purchase_confirm_no".localized, onOk: { [weak self] in
                self?.purchaseItem(gameItemId: gameItem.id)
            }, onCancel: { [weak self] in
                self?.itemListDataSource.blockPurchasing = false
            })
        }
    }
}
