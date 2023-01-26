//
//  StoreNewViewController.swift
//  kokonats
//
//  Created by George on 5/5/22.
//

import UIKit

class StoreNewViewController: UITableViewController {
    
    private var cellData = [CellData]()
    private let numberOfRows = 10
    
    var energyList = [EnergyItem]()
    var gameList = [GameDetail]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 44
        tableView.showsVerticalScrollIndicator = false
        view.backgroundColor = .kokoBgColor
        tableView.separatorStyle = .none
        registerCells()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        initializeData()
        refreshEnergy()
        fetchGameList()
    }
    
    private func registerCells() {
        tableView.register(EnergyListCell.self, forCellReuseIdentifier: "EnergyListCell")
        tableView.register(ItemsListCell.self, forCellReuseIdentifier: "ItemsListCell")
        tableView.register(LabelCell.self, forCellReuseIdentifier: "LabelCell")
        tableView.register(LogoCell.self, forCellReuseIdentifier: "LogoCell")
        tableView.register(BannerCell.self, forCellReuseIdentifier: "BannerCell")
    }
    
    private func initializeData() {
        
        energyList.removeAll()
        cellData.removeAll()
        gameList.removeAll()
        
        let energy = EnergyItem(id: 1, energyId: 1, energyItemName: "buy_energy".localized)
        energyList.append(energy)
        
        cellData.append(LogoCellData())
        cellData.append(BannerCellData())
        cellData.append(LabelCellData())
        cellData.append(EnergyCellData(energyItem: energy))
        cellData.append(LabelCellData())
        
        self.tableView.reloadData()
    }
    
    private func refreshEnergy() {
        ApiManager.shared.getEnergyBalance(idToken: LocalStorageManager.idToken) { [weak self] result in
            DispatchQueue.main.async {
                if let cell = self?.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? LogoCell {
                    if case .success(let data) = result {
                        cell.updateEnergy(energy: "\(data.formatedString())")
                    } else {
                        cell.updateEnergy(energy: "")
                    }
                }
            }
        }
    }
    
    private func fetchGameList() {
        ApiManager.shared.getGamesList(idToken: LocalStorageManager.idToken) { [weak self] result in
            DispatchQueue.main.async { [self] in
                guard let self = self else { return }
                switch result {
                case .success(let gameList):
                    self.gameList = gameList
                    self.cellData.append(ItemCellData(gameItem: gameList[0]))
                    self.tableView.reloadData()
                case .failure(let error):
                    Logger.debug("error: \(error.localizedDescription)")
                    break
                }
            }
        }
    }
    
    //MARK: - TableView
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = cellData[indexPath.section].cellHeight
        return height
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return cellData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 3:
            return energyList.count
        case 5:
            return gameList.count
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellData[indexPath.section].identifier) {
            if let cell = cell as? LabelCell, indexPath.section == 2 {
                cell.update("energy_item_title".localized)
            } else if let cell = cell as? LabelCell, indexPath.section == 4 {
                   cell.update("shop_item_title".localized)
            } else if let cell = cell as? EnergyListCell,
                      case .energyItem(let data) = cellData[indexPath.section].type {
                cell.updateEnergyItem(data)
            } else if let cell = cell as? ItemsListCell,
                      case .gameItem(_) = cellData[indexPath.section].type {
                let game = gameList[indexPath.row]
                cell.updateGameItem(game)
            }
            
            return cell
        }
        
        return UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let toVC: UIViewController?
        if indexPath.section == 3 {
            toVC = EnergyViewController()
        } else if indexPath.section == 5 {
            toVC = GameItemViewController()
            (toVC as! GameItemViewController).game = gameList[indexPath.row]
        } else {
            return
        }
        toVC?.modalPresentationStyle = .fullScreen
        self.present(toVC!, animated: true)
    }

}

extension StoreNewViewController {
    
    private func fetchGameDetailData(for game: GameDetail, completion: ((GameDetailData) -> ())? = nil) {
        var matches: [GameMatch] = []
        var tournaments: [TournamentClassDetail] = []
        
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        fetchPvpGameData(for: game.id) {matchList in
            matches = matchList
            dispatchGroup.leave()
        }
        dispatchGroup.enter()
        fetchTournamentGameData(for: game.id) { tcs in
            tournaments = tcs
            dispatchGroup.leave()
        }
        
        dispatchGroup.notify(queue: .main) {
            let gameData = GameDetailData(gameData: game, tournamentList: tournaments, matchList: matches)
            completion?(gameData)
        }
    }
    
    private func fetchPvpGameData(for id: Int, completion: (([GameMatch]) -> ())? = nil) {
        ApiManager.shared.getPVPMatches(idToken: LocalStorageManager.idToken, gameId: id) { result in
            switch result {
            case .success(let matchList):
                completion?(matchList)
            case .failure(let error):
                Logger.debug(error.localizedDescription)
                completion?([])
            }
        }
    }
    
    private func fetchTournamentGameData(for id: Int, completion: (([TournamentClassDetail]) -> ())? = nil) {
        ApiManager.shared.getTournamentClasses(forGameId: id) { result in
            switch result {
            case .success(let tcs):
                completion?(tcs)
            case .failure(let error):
                Logger.debug(error.localizedDescription)
                completion?([])
            }
        }
    }
}


extension StoreNewViewController: EventHandler {
    func HandleEvent(_ event: Event) {
    }
}


class LabelCellData: CellData {
    var identifier: String { return "LabelCell" }
    var type: CellType { return .label }
    var cellHeight: CGFloat { return 80 }
}


class EnergyCellData: CellData {
    private var energyItem: EnergyItem
    var type: CellType { return .energyItem(energyItem) }
    var cellHeight: CGFloat { return 100 }
    var identifier: String { return "EnergyListCell" }
    init(energyItem: EnergyItem) {
        self.energyItem = energyItem
    }
}

class ItemCellData: CellData {
    private var gameItem: GameDetail
    var type: CellType { return .gameItem(gameItem) }
    var cellHeight: CGFloat { return 100 }
    var identifier: String { return "ItemsListCell" }
    init(gameItem: GameDetail) {
        self.gameItem = gameItem
    }
}
