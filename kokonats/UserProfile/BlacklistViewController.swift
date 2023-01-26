//
//  BlacklistViewController.swift
//  kokonats
//
//  Created by smartdev0126 on 6/5/22.
//

import Foundation
import UIKit

class BlacklistViewController: UIViewController {
    private var blUsers: BlockedUsers!
    private var blockedUsers: [BlockedUser] = []
    private let blacklistTableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
    }
    func configureLayout() {
        // code for read blocked users
        fetchBlockedUsers()
        
        view.backgroundColor = .kokoBgColor
        
        let backButton = UIButton()
        view.addSubview(backButton)
        backButton.activeConstraints(to: view, directions: [.leading(.leading, 40), .top(.top, 40)])
        backButton.activeSelfConstrains([.height(40), .width(40)])
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
        
        let titleLabel = UILabel.formatedLabel(size: 34, text: "blacklist".localized, type: .bold, textAlignment: .left)
        titleLabel.numberOfLines = 0
        titleLabel.adjustsFontSizeToFitWidth = true
        view.addSubview(titleLabel)
        titleLabel.activeConstraints(directions: [.leading(.leading, 40), .top(.top, 103), .trailing(.trailing, -100)])
        titleLabel.activeSelfConstrains([.height(54)])
        
        blacklistTableView.delegate = self
        blacklistTableView.dataSource = self
        view.addSubview(blacklistTableView)
        blacklistTableView.activeConstraints(directions: [.leading(.leading, 40), .top(.top, 170)])
        blacklistTableView.activeSelfConstrains([.height(600), .width(view.frame.size.width - 60)])
        blacklistTableView.register(BlacklistItemTableViewCell.self, forCellReuseIdentifier: "BlacklistItemTableViewCell")
        blacklistTableView.backgroundColor = .clear
        blacklistTableView.isScrollEnabled = true
    }
    @objc func goBack(_ sender: UIButton) {
        self.dismiss(animated: false)
    }
    private func fetchBlockedUsers() {
        ApiManager.shared.getBlockUsers(idToken: LocalStorageManager.idToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let blUsers):
                    self.blUsers = blUsers
                    self.blockedUsers.removeAll()
                    self.blockedUsers = self.blUsers.blockedUsers
                    self.blacklistTableView.reloadData()
                case .failure(let error):
                    Logger.debug("error: \(error.localizedDescription)")
                    break
                }
            }
        }
    }
}
extension BlacklistViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return blockedUsers.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BlacklistItemTableViewCell") as! BlacklistItemTableViewCell
        
        let buser = blockedUsers[indexPath.row]
        
        cell.useravatar.image = UIImage(named: "avatar_\(buser.picture)")
        cell.usernameLable.text = buser.username
        cell.blockedDateLabel.text = timestampToDate(ts: buser.createTime)
        
        cell.buttonTapCallback = {
            let alert1 = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            alert1.addAction(UIAlertAction(title: "unblock".localized, style: .destructive , handler:{ (UIAlertAction)in
                print("click unblock button")
                self.didTapUnblock(index: indexPath)
            }))
            alert1.addAction(UIAlertAction(title: "cancel".localized, style: .cancel , handler:{ (UIAlertAction)in
                print("click cancel button")
            }))
            alert1.popoverPresentationController?.sourceRect = CGRect(x: self.view.bounds.midX, y: 0, width: 0, height: 50)
            alert1.popoverPresentationController?.sourceView = self.view
            self.present(alert1, animated: true) {
                print("option menu presented")
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    private func didTapUnblock(index: IndexPath) {
        let idx = index.row
        
        // remove blocked user by index from list
        let buser = blockedUsers[idx]
        ApiManager.shared.deleteBlockUser(idToken: LocalStorageManager.idToken, blockedUserId: buser.id) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(_):
                    Logger.debug("Delete blocked user success")
                    self.blockedUsers.remove(at: idx)
                    self.blacklistTableView.reloadData()
                case .failure(_):
                    Logger.debug("Delete blocked user error")
                }
            }
        }
    }
    private func timestampToDate(ts: Int) -> String {
        let date = NSDate(timeIntervalSince1970: TimeInterval(ts / 1000))
        let dayTimePeriodFormatter = DateFormatter()
        dayTimePeriodFormatter.dateFormat = "YYYY/MM/dd"
        let dateString = dayTimePeriodFormatter.string(from: date as Date)
        return dateString
    }
}
