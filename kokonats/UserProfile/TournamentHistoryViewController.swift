////  TournamentHistoryViewController.swift
//  kokonats
//
//  Created by sean on 2021/12/05.
//  
//

import Foundation
import UIKit

class TournamentHistoryViewController: UIViewController {
    private var historyItemList = [UserTournamentHistoryItem]()
    var gameList = [GameDetail]()
    private var _containerView: TournamentHistoryView?
    private let selectableButton = UIButton()
    private var buttonTitle = UILabel.formatedLabel(size: 14, text: "user_tnmhistory_all_allScore_button_title".localized, type: .bold, textAlignment: .left)

    private var selectedGameTitle: String?

    private var selectedTitleKoko: Int {
        return selectedTournamentList.reduce(0) { $0 + ($1.kokoAmount ?? 0) }
    }

    private var selectedTournamentList: [UserTournamentHistoryItem] {
        if let title = selectedGameTitle,
           let game = gameList.first(where: { ($0.name ?? String($0.id)) == title }) {
            let selected = historyItemList.filter {
                $0.gameId == game.id
            }
            return selected
        } else {
            return historyItemList
        }
    }

    private var dataCount: Int {
        return selectedTournamentList.count
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .kokoBgColor

        let containerView = TournamentHistoryView()
        view.addSubview(containerView)
        containerView.activeConstraints(to: view.safeAreaLayoutGuide, anchorDirections: [.top(), .bottom(), .trailing(), .leading()])
        containerView.update(dataSource: self, delegate: self)

        let button = UIButton()
        button.setImage(UIImage(named: "navigation_back"), for: .normal)
        view.addSubview(button)
        button.activeConstraints(to: view.safeAreaLayoutGuide, anchorDirections: [.leading(.leading, 24), .top(.top, 32)])
        button.activeSelfConstrains([.height(48), .width(48)])
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(closeAction), for: .touchUpInside)


        let bgImage = UIImageView.fromImage(name: "filter_button")
        bgImage.contentMode = .scaleAspectFit
        selectableButton.isUserInteractionEnabled = true
        selectableButton.addSubview(bgImage)
        bgImage.activeConstraints()

        selectableButton.addSubview(buttonTitle)
        buttonTitle.activeConstraints(directions: [.leading(.leading, 20), .top(.top, 14)])
        buttonTitle.activeSelfConstrains([.width(75), .height(25)])

        if #available(iOS 14.0, *) {
            selectableButton.showsMenuAsPrimaryAction = true
            selectableButton.menu = createButtonMenu()
        } else {
            // Fallback on earlier versions
        }
        view.addSubview(selectableButton)
        selectableButton.activeConstraints(to: button, directions: [.top(.bottom, 126), .leading()])
        selectableButton.activeSelfConstrains([.width(132), .height(56)])

        _containerView = containerView
        containerView.isUserInteractionEnabled = true
        _containerView?.update(koko: "\(selectedTitleKoko.formatedString())")
    }

    // in case the game name is empty, using the id as the name temporarily
    private var gameTitleList: [String] {
        return gameList.map { $0.name ?? String($0.id) }
    }

    private func createButtonMenu() -> UIMenu {
        var actionList = [UIAction]()
        let action = UIAction(title: "user_tnmhistory_all_allScore_button_title".localized) {
            self.selectGame(title: $0.title)
        }
        actionList.append(action)


        gameTitleList.forEach {
            let action = UIAction(title: $0) {
                self.selectGame(title: $0.title)
            }
            actionList.append(action)
        }

        let menu = UIMenu(title: "",  children: actionList)
        return menu
    }

    private func selectGame(title: String?) {
        guard let title = title else {
            return
        }

        if title == "user_tnmhistory_all_allScore_button_title".localized {
            selectedGameTitle = nil
        } else {
            selectedGameTitle = title
        }
        buttonTitle.text = title
        _containerView?.reloadHistory()
        _containerView?.update(koko: "\(selectedTitleKoko.formatedString())")
    }

    func update(data: [UserTournamentHistoryItem]) {
        self.historyItemList = data
        _containerView?.update(koko: "\(selectedTitleKoko.formatedString())")
    }

    @objc private func closeAction() {
        self.dismiss(animated: true)
    }
}

extension TournamentHistoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return dataCount
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TournamentHistoryItemTableViewCell") as! TournamentHistoryItemTableViewCell
        let tournamentRecord = selectedTournamentList[indexPath.section]
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

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 24
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }
}

