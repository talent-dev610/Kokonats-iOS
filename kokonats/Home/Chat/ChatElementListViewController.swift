//
//  ChatElementListViewController.swift
//  kokonats
//
//  Created by iori on 2022/03/05.
//

import UIKit

protocol ChatTabTogglable {
    func didSetThenShow(type: ChatMessageViewController.MessageType)
}

// FIXME: iOS 15.2 で search bar 入力後 テキストの位置が下にずれる問題
class ChatElementListViewController: UIViewController, ChatTransitionAnimatable {
    // share this value with ChatMessageVC to align height
    static let TopViewHeight: CGFloat = 60
    
    // MARK: - UI
    private var tableView = UITableView(frame: .zero)
    private var searchBar = UISearchBar(frame: .zero)
    var targetView: UIView { return searchBar } // ChatTransitionAnimatable
    
    // MARK: -
    private var dataSource: ChatElementDataSource!
    private var needToShowLoginAlert: Bool = false
    
    static func instantiateWithNav(type: ChatElementType) -> ChatNavigationController {
        let vc = Self()
        vc.dataSource = ChatElementDataSource(type: type)
        vc.needToShowLoginAlert = type == .user
        return ChatNavigationController(rootViewController: vc)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(showUnreadDot), name: .refreshUnreadDMDotItem, object: nil)
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.backButtonTitle = ""
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationController?.navigationBar.barTintColor = .clear
        navigationController?.navigationBar.backgroundColor = .clear
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !AppData.shared.isLoggedIn() && needToShowLoginAlert {
            needToShowLoginAlert = false
            showErrorMessage(title: "error_need_to_login_first".localized, reason: "")
        }
    }
    
    // MARK: - setup layout
    private func setup() {
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.backgroundColor = .clear
        setupSearchBar()
        setupTableView()
    }
    
    @objc private func showUnreadDot() {
        tableView.reloadData()
    }
    
    private func setupSearchBar() {
        searchBar.searchTextField.backgroundColor = .kokoBgGray2
        // to remove search icon on left side
        searchBar.setImage(UIImage(), for: .search, state: .normal)
        // to remove black border outside of text field
        searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        searchBar.searchTextPositionAdjustment = UIOffset(horizontal: 6, vertical: 0)
        searchBar.searchTextField.font = .getKokoFont(type: .medium, size: 14)
        searchBar.searchTextField.attributedPlaceholder = NSAttributedString(string: dataSource.type.placeholder, attributes: [.foregroundColor: UIColor.black.withAlphaComponent(0.4)])
        searchBar.delegate = self
        // to handle that the clear button has been pressed.
        searchBar.searchTextField.delegate = self
        view.addSubview(searchBar)
        searchBar.activeSelfConstrains([.height(Self.TopViewHeight)])
        searchBar.activeConstraints(to: view, directions: [.top(), .leading(.leading, 27), .trailing(.trailing, -27)])
    }
    
    private func setupTableView() {
        dataSource.registerCells(tableView) { [weak self] in
            self?.tableView.reloadData()
        }
        tableView.separatorStyle = .none
        tableView.dataSource = dataSource
        tableView.delegate = self
        tableView.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.activeConstraints(to: view, directions: [.top(.top, 60), .leading(), .trailing(), .bottom()])
    }
    
    // MARK: - search
    private func searchAndShowResult() {
        dataSource.search(text: searchBar.text)
    }
    
    @objc
    private func didTap() {
        navigationController?.popViewController(animated: true)
    }
}

extension ChatElementListViewController: ChatTabTogglable {
    func didSetThenShow(type: ChatMessageViewController.MessageType) {
        if let currentVc = navigationController?.topViewController as? ChatMessageViewController, currentVc.messageType == type {
            return // presenting already
        }
        let vc = ChatMessageViewController.instantiate(type: type)
        if let nav = navigationController as? ChatNavigationController {
            nav.pushMessageVC(vc: vc)
        } else {
            Logger.debug(className + "." + #function + ": something wrong!")
            // fall back
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

extension ChatElementListViewController: UITableViewDelegate {
    typealias ChatVC = ChatMessageViewController
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        guard let elem = dataSource.getElement(for: indexPath) else { return }
        let vc: ChatVC? = {
            switch elem.elementType {
            case .channel:
                return ChatVC.instantiate(type: .channel(threadId: elem.documentId!))
            case .user:
                guard let member = elem.thread.membersDetail?.first(where: { $0.id != AppData.shared.currentUser?.id }) else { return nil }
                // NOTE: この導線では .user でも必ず documentId は存在する。
                //       存在しないケースは channel 内で投稿しているユーザーアイコンをタップして
                //       初めて DM を送信する場合
                var chblocked: Bool = false
                var chblockuserName: String = ""
                ApiManager.shared.checkBlockedUser(idToken: LocalStorageManager.idToken, targetUserId: member.id!) { reuslt in
                    switch reuslt {
                    case .success(let blocked):
                        chblocked = blocked
                        chblockuserName = member.userName!
                    case .failure(let error):
                        Logger.debug("check blocked user error: \(error.localizedDescription)")
                        break
                    }
                }
                if chblocked {
                    let message: String!
                    if Locale.current.languageCode == "en" {
                        message = "You have been blocked by \r\n \(chblockuserName)"
                    } else {
                        message = "\(chblockuserName) \r\n にブロックされた"
                    }
                    showConfirmDialog(type: .close, title: "BLOCK", message: message, textOk: "OK", textCancel: "BACK", onOk: nil, onCancel: nil)
                }
                return ChatVC.instantiate(type: .dm(threadId: elem.documentId, member: member))
            }
        }()
        if let vc = vc {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ChatElementListViewController: UISearchBarDelegate {
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        return true
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        searchAndShowResult()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchAndShowResult()
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

extension ChatElementListViewController: UITextFieldDelegate {
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.searchBar.resignFirstResponder()
        }
        return true
    }
}
