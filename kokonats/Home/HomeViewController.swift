////  HomeViewController.swift
//  kokonats
//
//  Created by sean on 2021/09/16.
//  
//

import Foundation
import UIKit
import WebKit

class HomeViewController: UIViewController {
    // MARK: - UI
    private var tableView = UITableView(frame: .zero)
    
    // MARK: -
    private var cellData = [CellData]()
    private var tournamentDetailList = [TournamentClassDetail]()
    private var gameDetailList = [GameDetail]()
    private let numberOfRows = 4

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        registerCells()
        initializeData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        refreshEnergy()
    }
    
    private func setupLayout() {
        view.addSubview(tableView)
        tableView.activeConstraints(to: view, directions: [.top(), .leading(), .bottom(), .trailing()])
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.estimatedRowHeight = 44
        tableView.showsVerticalScrollIndicator = false
        tableView.backgroundColor = .kokoBgColor
        view.backgroundColor = .kokoBgColor
        tableView.separatorStyle = .none
    }

    private func registerCells() {
        tableView.register(TournamentListCell.self, forCellReuseIdentifier: "TournamentListCell")
        tableView.register(GameListCell.self, forCellReuseIdentifier: "GameListCell")
        tableView.register(LogoCell.self, forCellReuseIdentifier: "LogoCell")
        tableView.register(BannerCell.self, forCellReuseIdentifier: "BannerCell")
    }

    private func initializeData() {
        cellData.append(LogoCellData())
        cellData.append(BannerCellData())
        cellData.append(TournamentListData(tournamentList: [TournamentClassDetail]()))
        cellData.append(GameListData(gameList: [GameDetail]()))

        ApiManager.shared.getTournamentClasses(idToken: LocalStorageManager.idToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let data):
                    self.cellData[2] = TournamentListData(tournamentList: data)
                    AppData.shared.updateTournmentListInfo(data)
                    self.tableView.reloadData()
                case .failure(let error):
                    Logger.debug("error: \(error.localizedDescription)")
                    break
                }
            }
        }

        ApiManager.shared.getGamesList(idToken: LocalStorageManager.idToken) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                switch result {
                case .success(let gameList):
                    self.cellData[3] = GameListData(gameList: gameList)
                    AppData.shared.updateGameListInfo(gameList)
                    self.tableView.reloadData()
                case .failure(let error):
                    Logger.debug("error: \(error.localizedDescription)")
                    break
                }
            }
        }
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

    

    var tournamentList: [TournamentClassDetail] {
        if case .tournamentList(let data) = cellData[2].type {
            return data
        }
        return [TournamentClassDetail]()
    }

    var gameList: [GameDetail] {
        if case .gameList(let list) = cellData[3].type {
            return list
        }
        return [GameDetail]()
    }
}

extension HomeViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return cellData.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellData[indexPath.section].identifier) {
            if let cell = cell as? TournamentListCell,
               case .tournamentList(let data) = cellData[indexPath.section].type {
                cell.eventHandler = self
                cell.configure(with: .tournamentList(data))
            } else if let cell = cell as? GameListCell,
                      case .gameList(let data) = cellData[indexPath.section].type {
                cell.eventHandler = self
                cell.updateGameList(data)
            }
            return cell
        }
        return UITableViewCell()
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let height = cellData[indexPath.section].cellHeight
        return height
    }
}

extension HomeViewController {
    private func showGameDetailVC(id: Int) {
        guard let game = gameList.first(where: { $0.id == id }) else { return }
        
        fetchGameDetailData(for: game) { [weak self] gameData in
            let gameVC = GameDetailViewController()
            gameVC.gameDetailData = gameData
            self?.present(gameVC, animated: true, completion: nil)
        }
    }
    
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

enum Event {
    case showGameDetail(gameId: Int)
    case showTournament(tournamentId: Int)
    case playGame
    case playTournament
    case startMatching(matchClassId: Int)
    case error(message: String)
    case unknown
}

protocol EventHandler {
    func HandleEvent(_ event: Event)
}

extension HomeViewController: EventHandler {
    func HandleEvent(_ event: Event) {
        switch event {
        case .showGameDetail(let id):
            self.showGameDetailVC(id: id)
        case .playTournament:
            let playgroundVC = PlaygroundViewController()
            playgroundVC.modalPresentationStyle = .fullScreen
            playgroundVC.modalTransitionStyle = .crossDissolve
            present(playgroundVC, animated: false, completion: nil)
            return
        case .playGame:
            return
        case .showTournament(let tournamentClassId):
            guard let tournamentVC = UIStoryboard.buildVC(from: "TournamentDetail") as? TournamentDetailViewController,
                  let tournamentDetail = tournamentList.first(where: { $0.id == tournamentClassId }) else {
                Logger.debug("something is wrong")
                return
            }
            ApiManager.shared.getPlayableTournament(tournamentId: String(tournamentClassId), idToken: LocalStorageManager.idToken) { [weak self] result in
                let info: PlayableInfo = {
                    switch result {
                    case .success(let tournament): return PlayableInfo(tournamentClass: tournamentDetail, tournament: tournament)
                    case .failure(let error):
                        Logger.debug("showTournament w/tcid = \(tournamentClassId) is not available: \(error)")
                        return PlayableInfo(tournamentClass: tournamentDetail)
                    }
                }()
                tournamentVC.playable = info
                self?.present(tournamentVC, animated: true, completion: nil)
            }

        default:
            break
        }
    }
}

enum CellType {
    case logo
    case banner
    case label
    case tournamentList([TournamentClassDetail])
    case gameList([GameDetail])
    case energyItem(EnergyItem)
    case gameItem(GameDetail)

    var identifier: String {
        switch self {
        case .logo:
            return "LogoCell"
        case .banner:
            return "BannerCell"
        case .gameList:
            return "GameListCell"
        case .tournamentList:
            return "TournamentListCell"
        case .energyItem:
            return "EnergyListCell"
        case .gameItem:
            return "ItemListCell"
        case .label:
            return "LabelCell"
        }
    }
}

protocol CellData {
    var type: CellType { get }
    var cellHeight: CGFloat { get }
    var identifier: String { get }
    func initializeData()
}

extension CellData {
    func initializeData() { }
}

class LogoCellData: CellData {
    var identifier: String { return "LogoCell" }
    var type: CellType { return .logo }
    var cellHeight: CGFloat { return 49 + 13 }
}

class BannerCellData: CellData {
    var type: CellType { return .banner }
    var cellHeight: CGFloat { return 42 + 24 }
    var identifier: String { return "BannerCell" }
}

class TournamentListData: CellData {
    private var tournamentDetailList: [TournamentClassDetail]

    var type: CellType { return .tournamentList(tournamentDetailList) }
    var cellHeight: CGFloat { return 514 }
    var identifier: String { return "TournamentListCell" }
    // TODO: initialize the data structure
    init(tournamentList: [TournamentClassDetail]) {
        self.tournamentDetailList = tournamentList
    }
}

class GameListData: CellData {
    private var gameList: [GameDetail]
    var type: CellType { return .gameList(gameList) }
    var cellHeight: CGFloat { return 357 }
    var identifier: String { return "GameListCell" }
    init(gameList: [GameDetail]) {
        self.gameList = gameList
    }
}

extension UIImageView {
    static func getAddingEnergyView(with gestureReg: UITapGestureRecognizer) -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "add_energy_icon"))
        imageView.addGestureRecognizer(gestureReg)
        return imageView
    }
}

extension UIView {
    func dropShadow(cornerRadius: CGFloat) {
        self.layer.cornerRadius = cornerRadius
           
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1
           
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        self.layer.shadowRadius = 3
           
        self.layer.masksToBounds = false
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
    }
    
    func shadow(offset: CGSize, radius: CGFloat, color: CGColor, opacity: Float) {
        self.layer.shadowOffset = offset
        self.layer.shadowRadius = radius
        self.layer.shadowColor = color
        self.layer.shadowOpacity = opacity
    }
}
