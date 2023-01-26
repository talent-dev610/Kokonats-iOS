//
//  EnergyViewController.swift
//  kokonats
//
//  Created by George on 2022-05-06.
//

import Foundation
import UIKit
import StoreKit
import SwiftUI

class EnergyViewController: UIViewController {
    private var scrollView = UIScrollView()
    private var energyCollectionView: UICollectionView!
    private var energyScoreLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshEnergy()
    }
    
    private func configureLayout() {
        self.view.backgroundColor = .kokoBgColor
        
        let backButton = UIButton()
        view.addSubview(backButton)
        backButton.activeConstraints(directions: [.leading(.leading, 24), .top(.top, 70)])
        backButton.activeSelfConstrains([.height(50), .width(50)])
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
        
        let title = UILabel.formatedLabel(size: 34, text: "energy_item_title".localized, type: .bold, textAlignment: .left)
        view.addSubview(title)
        title.activeConstraints(to: backButton, directions: [.top(.top, 5), .leading(.trailing, 20)])
        title.activeSelfConstrains([.height(40)])
        
        let energyBg = UIView()
        energyBg.cornerRadius = 20
        energyBg.backgroundColor = .kokoLightYellow
        view.addSubview(energyBg)
        energyBg.activeSelfConstrains([.width(295), .height(60)])
        energyBg.activeConstraints(directions: [.centerX])
        energyBg.activeConstraints(to: title, directions: [.top(.bottom, 24)])
        let energyIcon = UIImageView(image: UIImage(named: "energy_icon"))
        view.addSubview(energyIcon)
        energyIcon.activeConstraints(to: energyBg, directions: [.leading(.leading, 22), .centerY])
        energyIcon.activeSelfConstrains([.height(30), .width(16)])
        
        energyScoreLabel = UILabel.formatedLabel(size: 24, type: .bold, textAlignment: .center)
        view.addSubview(energyScoreLabel)
        energyScoreLabel.activeConstraints(to: energyBg, directions: [.leading(.leading, 23), .centerY, .trailing(.trailing, 1), .top(), .bottom()])
        energyScoreLabel.text = ""
        
        let energyListLayout = UICollectionViewFlowLayout()
        energyListLayout.scrollDirection = .vertical
        energyListLayout.itemSize = CGSize(width: (screenSize.width - 80)/3.0, height: 140)
        energyListLayout.minimumLineSpacing = 18
        energyListLayout.sectionInset = UIEdgeInsets(top: 0, left: 24, bottom: 0, right: 24)
        energyCollectionView = UICollectionView(frame: .zero, collectionViewLayout: energyListLayout)
        energyCollectionView.register(StoreEnergyListCollectionViewCell.self, forCellWithReuseIdentifier: "StoreEnergyListCollectionViewCell")
        energyCollectionView.delegate = self
        energyCollectionView.dataSource = self
        view.addSubview(energyCollectionView)
        energyCollectionView.backgroundColor = .clear
        energyCollectionView.activeConstraints(to: energyBg, directions: [.centerX, .top(.bottom, 40)])
        energyCollectionView.isScrollEnabled = false
        energyCollectionView.isUserInteractionEnabled = true
        energyCollectionView.activeSelfConstrains([.width(view.frame.size.width), .height(600)])
    }
    
    @objc func goBack(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    private func refreshEnergy() {
        ApiManager.shared.getEnergyBalance(idToken: LocalStorageManager.idToken) { result in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    self.energyScoreLabel.text = "\(data.formatedString())"
                } else {
                    self.energyScoreLabel.text = ""
                }
            }
        }
    }
    
    private func handleFailure(title: String, reason: String, completion: @escaping (Bool) -> Void) {
        self.showAlertDialog(title: title, message: reason, textOk: "OK")
    }

}

extension EnergyViewController: PurchaseManagerDelegate {
    func purchaseManagerDidPurchaseKoko(transaction: SKPaymentTransaction, completion: @escaping () -> Void) {
        if true {
            self.refreshEnergy()
            self.showAlertDialog(title: "購入が成功しました。", message: "マイページで確認してください。", textOk: "OK")
        } else {

        }
    }

    func purchaseManagerFailedPurchaseKoko(transaction: SKPaymentTransaction, reason: Int) {
        var message = ""
        if reason == 1 {
            message = "In-app purchase failed"
        } else {
            message = "Purchase verify failed"
        }
        let error: String = transaction.error?.localizedDescription ?? "failed to puchase koko"
        self.showAlertDialog(title: "購入が失敗しました。", message: message, textOk: "OK")
    }
}

private class EnergyTapGesture: UITapGestureRecognizer {
    var type: KokoProductType?
}

extension EnergyViewController: UICollectionViewDataSource {
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return StoreManager.energyProductList.count
        }

        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let energyItem = StoreManager.energyProductList[indexPath.row]
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoreEnergyListCollectionViewCell", for: indexPath) as! StoreEnergyListCollectionViewCell
            let tapAction = EnergyTapGesture(target: self, action: #selector(purchaseEngergyAction(sender:)))
            tapAction.type = energyItem
            cell.addGestureRecognizer(tapAction)
            cell.update(energyItem: energyItem, hideRecommend: indexPath.row != 0)
            return cell
        }
    
    @objc private func purchaseEngergyAction(sender: UIGestureRecognizer) {
        sender.view?.clickEffect()
        guard AppData.shared.isLoggedIn() else {
            NotificationCenter.default.post(name: .needLogin, object: nil)
            return
        }
        if let energyTapAction = sender as? EnergyTapGesture,
           let type = energyTapAction.type {
            guard let product = StoreManager.shared.product(identifier: type.identifier) else {
                handleFailure(title: "購入が失敗しました", reason: "まだ対応中ですので、購入ができません。") { _ in
                }
                return
            }
            PurchaseManager.shared.delegate = self
            PurchaseManager.shared.buy(product)
        }
    }
}

extension EnergyViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                  layout collectionViewLayout: UICollectionViewLayout,
                  insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 24.0, bottom: 0.0, right: 24.0)
    }

    func collectionView(_ collectionView: UICollectionView,
                   layout collectionViewLayout: UICollectionViewLayout,
                   sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (screenSize.width - 80)/3.0, height: 140)
    }
}
