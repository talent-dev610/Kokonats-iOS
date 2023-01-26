////  UserProfileViewController.swift
//  kokonats
//
//  Created by sean on 2021/09/16.
//  
//

import Foundation
import UIKit
import FirebaseAuth

class UserProfileViewController: UIViewController {
    
    private var scrollView = UIScrollView()
    private var iconView: UIImageView!
    private var settingButton: UIButton!
    private var uidLabel: UILabel!
    private var userNameLabel: UILabel!
    private var historyTableView: UITableView!
    private var energyScoreLabel: UILabel!
    private var kokoBalanceLabel: UILabel!
    private var dataSource = [UserTournamentHistoryItem]()
    private var gameList: [GameDetail]? = nil
    private var user: UserInfo?
    
    // the last cell is show more button
    private var tableViewCellCount: Int {
        if dataSource.count >= 3 {
            return 5
        } else if dataSource.count == 0 {
            return 2
        } else {
            return dataSource.count + 2
        }
    }
    
    private var idToken: String {
        return LocalStorageManager.idToken
    }
    
    var shouldShowMorebutton: Bool {
        return dataSource.count > 0 ? true : false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        refreshAll()
    }
    
    private func refreshAll(showSignupViewIfNeeded: Bool  = true) {
        refreshUserInfo(showSignupViewIfNeeded: showSignupViewIfNeeded)
        refreshEnergy()
        refreshHistoryTableView()
        refreshKoko()
        
        if let gameList = AppData.shared.gameList {
            self.gameList = gameList
            return
        } else {
            fetchGameList()
        }
    }
    
    private func fetchGameList(completion: (() -> Void)? = nil) {
        ApiManager.shared.getGamesList(idToken: LocalStorageManager.idToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let gameList):
                    AppData.shared.updateGameListInfo(gameList)
                    self.gameList = gameList
                case .failure(let error):
                    Logger.debug("error: \(error.localizedDescription)")
                }
                completion?()
            }
        }
    }
    
    private func refreshUserInfo(showSignupViewIfNeeded: Bool  = true) {
        AppData.shared.getCurrentUser(showSignupViewIfNeeded: showSignupViewIfNeeded) { [weak self] userInfo in
            DispatchQueue.main.async {
                if let self = self,
                   let userInfo = userInfo {
                    self.configureView(with: userInfo)
                    self.user = userInfo
                }
            }
        }
    }
    
    private func refreshEnergy() {
        ApiManager.shared.getEnergyBalance(idToken: idToken) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    self?.energyScoreLabel.text = "\(data.formatedString())"
                }
            }
        }
    }
    
    private func refreshKoko() {
        ApiManager.shared.getKokoBalance(idToken: idToken) { [weak self] result in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    // in case this value is formatted at server side.
                    let koko: String = {
                        if let koko = Int(data.confirmed) {
                            return koko.formatedString()
                        } else {
                            return data.confirmed
                        }
                    }()
                    self?.kokoBalanceLabel.text = "\(koko)"
                }
            }
        }
    }
    
    private func refreshHistoryTableView() {
        ApiManager.shared.getTournamenHistory(idToken: LocalStorageManager.idToken) {[weak self] result in
            DispatchQueue.main.async {
                if case .success(let data) = result {
                    self?.dataSource = data
                    self?.view.layoutIfNeeded()
                    self?.historyTableView.reloadData()
                }
            }
        }
    }
    
    private func configureView(with userInfo: UserInfo) {
        userNameLabel.text = userInfo.userName
        uidLabel.text = String(userInfo.id)
        iconView.image = UIImage(named: "avatar_\(userInfo.picture ?? "5")")
    }
    
    private func configureLayout() {
        view.addSubview(scrollView)
        scrollView.activeConstraints(to: view)
        
        let containerView = UIView()
        scrollView.addSubview(containerView)
        containerView.activeConstraints(to: scrollView.contentLayoutGuide,  anchorDirections: [.top(), .leading(), .bottom(), .trailing()])
        containerView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor).isActive = true
        
        //logout button
        let logoutBgView = UIView()
        logoutBgView.backgroundColor = UIColor(red: 50/255, green: 55/255, blue: 85/255, alpha: 1)
        logoutBgView.layer.cornerRadius = 10
        containerView.addSubview(logoutBgView)
        logoutBgView.activeConstraints(directions: [.top(.top, 53), .trailing(.trailing, -24)])
        logoutBgView.activeSelfConstrains([.width(100), .height(40)])
        let logoutLabel = UILabel.formatedLabel(size: 14, text: "user_logout_label".localized, type: .black, textAlignment: .center)
        logoutLabel.layer.cornerRadius = 10
        logoutLabel.clipsToBounds = true
        containerView.addSubview(logoutLabel)
        logoutLabel.backgroundColor = .kokoBgColor
        logoutLabel.textColor = .lightWhiteFontColor
        logoutLabel.activeConstraints(to: logoutBgView, directions: [.top(.top, 1), .leading(.leading, 1), .bottom(.bottom, -1), .trailing(.trailing, -1)])
        let logoutGR = UITapGestureRecognizer(target: self, action: #selector(logoutAction))
        logoutBgView.addGestureRecognizer(logoutGR)
        
        iconView = UIImageView()
        iconView.backgroundColor = .kokoBgColor
        containerView.addSubview(iconView)
        iconView.activeConstraints(to: containerView, directions: [.top(.top, 131), .centerX])
        iconView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        iconView.cornerRadius = 45
        
        settingButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        settingButton.backgroundColor = .clear
        containerView.addSubview(settingButton)
        settingButton.setBackgroundImage(UIImage(named: "settings"), for: .normal)
        settingButton.activeConstraints(to: iconView, directions: [.leading(.trailing, 15), .centerY])
        settingButton.addTarget(self, action: #selector(gotoEdit(_:)), for: .touchUpInside)
        
        
        uidLabel = UILabel.formatedLabel(size: 12)
        containerView.addSubview(uidLabel)
        uidLabel.activeConstraints(to: containerView, directions: [.centerX, .leading(), .trailing()])
        uidLabel.activeConstraints(to: iconView, directions: [.top(.bottom, 21)])
        uidLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        userNameLabel = UILabel.formatedLabel(size: 20, type: .bold)
        containerView.addSubview(userNameLabel)
        userNameLabel.activeConstraints(to: containerView, directions: [.centerX, .leading()])
        userNameLabel.activeConstraints(to: uidLabel, directions: [.top(.bottom, 7)])
        userNameLabel.heightAnchor.constraint(equalToConstant: 27).isActive = true
        
        let kokoBg = UIView()
        kokoBg.cornerRadius = 20
        kokoBg.backgroundColor = .dollarYellow
        containerView.addSubview(kokoBg)
        kokoBg.activeSelfConstrains([.height(60)])
        kokoBg.activeConstraints(to: containerView, directions: [.leading(.leading, 24), .centerX])
        kokoBg.activeConstraints(to: userNameLabel, directions: [.top(.bottom, 16)])
        
        let iconContainer = UIView()
        iconContainer.backgroundColor = .clear
        containerView.addSubview(iconContainer)
        iconContainer.activeConstraints(to: kokoBg, directions: [.top(), .bottom(), .centerX])
        
        let kokoIcon = UIImageView(image: UIImage(named: "dollar_icon"))
        containerView.addSubview(kokoIcon)
        kokoIcon.activeConstraints(to: iconContainer, directions: [.leading(), .centerY])
        kokoIcon.activeSelfConstrains([.height(40), .width(40)])
        
        kokoBalanceLabel = UILabel.formatedLabel(size: 28, text: "0", type: .bold, textAlignment: .left)
        containerView.addSubview(kokoBalanceLabel)
        kokoBalanceLabel.activeConstraints(to: iconContainer, directions: [.trailing(.trailing, 1), .top(), .bottom()])
        kokoBalanceLabel.activeConstraints(to: kokoIcon, directions: [.leading(.trailing, 25)])
        
        let energyBg = UIView()
        energyBg.cornerRadius = 20
        energyBg.backgroundColor = .lightBgColor
        containerView.addSubview(energyBg)
        energyBg.activeSelfConstrains([.height(60)])
        energyBg.activeConstraints(to: containerView, directions: [.leading(.leading, 24), .centerX])
        energyBg.activeConstraints(to: kokoBg, directions: [.top(.bottom, 24)])
        let energyIcon = UIImageView(image: UIImage(named: "energy_icon"))
        containerView.addSubview(energyIcon)
        energyIcon.activeConstraints(to: energyBg, directions: [.leading(.leading, 11), .centerY])
        energyIcon.activeSelfConstrains([.height(30), .width(16)])
        
        let addEnergyView = UIImageView(image: UIImage(named: "add_energy_icon"))
        containerView.addSubview(addEnergyView)
        addEnergyView.isUserInteractionEnabled = true
        addEnergyView.activeConstraints(to: energyBg, directions: [.trailing(.trailing, -12), .centerY])
        addEnergyView.activeSelfConstrains([.height(24), .width(24)])
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(addEnergyAction))
        addEnergyView.addGestureRecognizer(tapGR)
        
        energyScoreLabel = UILabel.formatedLabel(size: 18, type: .black, textAlignment: .left)
        containerView.addSubview(energyScoreLabel)
        energyScoreLabel.activeConstraints(to: energyBg, directions: [.leading(.leading, 39), .centerY, .trailing(.trailing, 1), .top(), .bottom()])
        
        let historyTitleLabel = UILabel.formatedLabel(size: 14, text: "user_tnmhistory_title".localized, textAlignment: .left)
        containerView.addSubview(historyTitleLabel)
        historyTitleLabel.activeConstraints(to: energyBg, directions: [.top(.bottom, 30), .leading(), .trailing()])
        historyTitleLabel.activeSelfConstrains([.height(19)])
        
        historyTableView = UITableView()
        historyTableView.showsVerticalScrollIndicator = false
        historyTableView.backgroundColor = .kokoBgColor
        historyTableView.tableFooterView = UIView()
        containerView.addSubview(historyTableView)
        historyTableView.activeConstraints(to: containerView, directions: [.leading(.leading, 24), .bottom(), .centerX])
        historyTableView.activeConstraints(to: historyTitleLabel, directions: [.top(.bottom, 24)])
        historyTableView.activeSelfConstrains([.height(500)])
        historyTableView.dataSource = self
        historyTableView.delegate = self
        historyTableView.estimatedRowHeight = 90
        historyTableView.isScrollEnabled = false
        historyTableView.register(TournamentHistoryItemTableViewCell.self, forCellReuseIdentifier: "TournamentHistoryItemTableViewCell")
        historyTableView.register(TournamentShowMoreTableViewCell.self, forCellReuseIdentifier: "TournamentShowMoreTableViewCell")
        historyTableView.register(TournamentSupportTableViewCell.self, forCellReuseIdentifier: "TournamentSupportTableViewCell")
        historyTableView.register(BlacklistTableViewCell.self, forCellReuseIdentifier: "BlacklistTableViewCell")
    }
    
    private func clearUserData() {
        uidLabel.text = ""
        userNameLabel.text = ""
        energyScoreLabel.text = ""
        kokoBalanceLabel.text = ""
        dataSource.removeAll()
        historyTableView.reloadData()
    }
    
    @objc func addEnergyAction() {
        NotificationCenter.default.post(name: .showEnergyStore, object: nil)
    }
    
    @objc func logoutAction() {
        self.showConfirmDialog(title: "user_logout_message_title".localized, message: "", textOk: "user_logout_ok".localized, textCancel: "user_logout_cancel".localized, onOk: { [weak self] in
            do {
              try Auth.auth().signOut()
            } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
            }
            AppData.shared.logout()
            self?.refreshAll(showSignupViewIfNeeded: false)
            self?.clearUserData()
        })
    }
    
    @objc func gotoEdit(_ sender: UIButton) {
        let toVC = EditProfileViewController()
        toVC.user = self.user
        toVC.modalPresentationStyle = .fullScreen
        self.present(toVC, animated: false)
    }
}


extension UserProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section >= tableViewCellCount - 3 {
            return 48
        }
        return 90
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section + 1 == tableViewCellCount {
            let toVC = BlacklistViewController()
            toVC.modalPresentationStyle = .fullScreen
            self.present(toVC, animated: false)
        } else if indexPath.section + 3 == tableViewCellCount, shouldShowMorebutton {
            let historyVC = TournamentHistoryViewController()
            historyVC.modalPresentationStyle = .fullScreen
            historyVC.update(data: dataSource)
            if let gameList = gameList {
                historyVC.gameList = gameList
                self.show(historyVC, sender: self)
            } else {
                fetchGameList() { [weak self] in
                    guard let self = self else { return }
                    historyVC.gameList = self.gameList ?? [GameDetail]()
                    self.show(historyVC, sender: self)
                }
            }
        } else if indexPath.section + 2 == tableViewCellCount {
            guard let url = URL(string: "https://game.kokonats.club/support") else { return }
            UIApplication.shared.open(url)
        }
    }
}

extension UserProfileViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewCellCount
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let spaceView = UIView()
        spaceView.backgroundColor = .kokoBgColor
        return spaceView
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section + 2 == tableViewCellCount {
            // show button for last cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentSupportTableViewCell") as! TournamentSupportTableViewCell
            
            return cell
        } else if indexPath.section + 3 == tableViewCellCount {
            // show button for last cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentShowMoreTableViewCell") as! TournamentShowMoreTableViewCell
            
            return cell
        } else if indexPath.section + 1 == tableViewCellCount {
            // show button for last cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "BlacklistTableViewCell") as! BlacklistTableViewCell
            
            return cell
        } else if let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentHistoryItemTableViewCell") as? TournamentHistoryItemTableViewCell {
            let tournamentRecord = dataSource[indexPath.section]
            var date: Date?
            tournamentRecord.timestamp.flatMap {
                date = Date(timeIntervalSince1970: Double($0/1000))
            }
            
            let titleName: String = (tournamentRecord.tournamentName ?? tournamentRecord.matchName) ?? ""
            cell.updateView(TournamentHistoryItemTableViewCell.DataModel(title: titleName,
                                                                         date: date?.kokoFormated(),
                                                                         koko: tournamentRecord.kokoAmount ?? 0,
                                                                         spentEnergy: tournamentRecord.energy ?? 0))
            return cell
            
        }
        return UITableViewCell()
    }
}
