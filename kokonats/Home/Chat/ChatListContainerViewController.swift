//
//  ChatListContainerViewController.swift
//  kokonats
//
//  Created by iori on 2022/03/05.
//

import UIKit

class ChatListContainerViewController: UIViewController {
    private static let AllowSwipePaging: Bool = true
    private var dotUnread = UIView()
    
    enum Tabs: Int, CaseIterable {
        // sync with index of vcs
        case channel = 0, message = 1, support = 2
        var name: String {
            switch self {
            case .channel: return "chat.elem.channel".localized
            case .message: return "chat.elem.message".localized
            case .support: return "chat.elem.support".localized
            }
        }
    }
    
    private var tabButtons: [UIButton] = []
    private let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private lazy var vcs: [UIViewController] = Tabs.allCases.map { tab in
        let vc: UIViewController = {
            switch tab {
            case .channel: return ChatElementListViewController.instantiateWithNav(type: .channel)
            case .message: return ChatElementListViewController.instantiateWithNav(type: .user)
            case .support: return ChatMessageViewController.instantiate(type: .support)
            }
        }()
        vc.title = tab.name
        return vc
    }
    private var currentPageIndex: Int = 0
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        // NOTE: ユーザーがログイン済みで currentUser が nil ならセットする
        if AppData.shared.isLoggedIn() && AppData.shared.currentUser == nil {
            ApiManager.shared.getUserInfo(idToken: LocalStorageManager.idToken) { _ in }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(self.switchTab(noti:)), name: .needToSwitchChatTab, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUnreadDot), name: .refreshUnreadDMDotTab, object: nil)
        ChatManager.shared.fetchLastReadAt() {_ in
            
        }
    }
    
    // MARK: - setup layout
    private func setup() {
        view.backgroundColor = UIColor.kokoBgColor.withAlphaComponent(0.95)
        let headerView = UIView()
        let contentView = UIView()
        view.addSubview(headerView)
        view.addSubview(contentView)
        headerView.activeSelfConstrains([.height(120)])
        headerView.activeConstraints(to: view.safeAreaLayoutGuide, anchorDirections: [.top()])
        headerView.activeConstraints(to: view, directions: [.leading(.leading, 35), .trailing(.trailing, -35)])
        contentView.activeConstraints(to: headerView, directions: [.top(.bottom, 10)])
        contentView.activeConstraints(to: view, directions: [.leading(), .trailing(), .bottom()])
        
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(UIImage(named: "close_button"), for: .normal)
        closeButton.addTarget(self, action: #selector(self.didTapCloseButton), for: .touchUpInside)
        headerView.addSubview(closeButton)
        closeButton.activeSelfConstrains([.width(40), .height(40)])
        closeButton.activeConstraints(to: headerView, directions: [.top(.top, 20), .trailing()])
        
        setupTabs(to: headerView)
        setupForPageVC(to: contentView)
    }
    
    private func setupTabs(to baseView: UIView) {
        tabButtons = vcs.enumerated().map { index, vc in
            let button = UIButton(type: .custom)
            button.tag = index
            button.setTitle(vc.title, for: .normal)
            button.titleLabel?.font = .getKokoFont(type: .medium, size: 17)
            button.backgroundColor = .kokoBgGray
            button.cornerRadius = 14
            button.addTarget(self, action: #selector(self.didTapTab(sender:)), for: .touchUpInside)
            return button
        }

        let stackView = UIStackView(arrangedSubviews: tabButtons)
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.backgroundColor = .clear
        baseView.addSubview(stackView)
        stackView.activeConstraints(to: baseView, directions: [.top(.top, 80), .leading(), .trailing()])
        stackView.activeSelfConstrains([.height(38)])
        
        view.addSubview(self.dotUnread)
        self.dotUnread.activeSelfConstrains([.width(20), .height(20)])
        self.dotUnread.activeConstraints(to: tabButtons[1], directions: [.trailing(.trailing, 5), .top(.top, -5)])
        self.dotUnread.backgroundColor = .kokoYellow
        self.dotUnread.dropShadow(cornerRadius: 10)
        if (AppData.shared.unreadThreads.isEmpty) {
            self.dotUnread.isHidden = true
        } else {
            self.dotUnread.isHidden = false
        }
        
    }
    
    @objc private func showUnreadDot() {
        if AppData.shared.unreadThreads.isEmpty {
            self.dotUnread.isHidden = true
        } else {
            self.dotUnread.isHidden = false
        }
    }
    
    private func setupForPageVC(to baseView: UIView) {
        pageVC.willMove(toParent: self)
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.view.activeConstraints(to: baseView, directions: [.top(), .bottom(), .leading(), .trailing()])
        
        // NOTE: if koko allows paging, set self to dataSource, delegate
        if Self.AllowSwipePaging {
            pageVC.dataSource = self
            pageVC.delegate = self
        }
        setPage(to: 0)
        setTab(to: 0)
    }
    
    // MARK: - switch page or tab
    private func setPage(to index: Int, animated: Bool = true) {
        guard let nextVC = vcs[safe: index] else { return }
        if !animated {
            pageVC.setViewControllers([nextVC], direction: .forward, animated: false)
            return
        }
        nextVC.view.alpha = 0.5
        pageVC.setViewControllers([nextVC], direction: .forward, animated: false)
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseIn) { [weak nextVC] in
            nextVC?.view.alpha = 1
        }
    }
    
    private func setTab(to index: Int, animated: Bool = true) {
        let selected = tabButtons.filter { $0.tag == index }
        let others = tabButtons.filter { $0.tag != index }
        if !animated {
            selected.forEach { $0.backgroundColor = .kokoOrange }
            others.forEach { $0.backgroundColor = .kokoBgGray }
            return
        }
        UIView.animate(withDuration: 0.4) {
            selected.forEach { $0.backgroundColor = .kokoOrange }
            others.forEach { $0.backgroundColor = .kokoBgGray }
        }
    }
    
    private func setTabAndPage(to index: Int, animated: Bool = true) {
        guard currentPageIndex != index else { return }
        setTab(to: index, animated: animated)
        setPage(to: index, animated: animated)
        currentPageIndex = index
    }
    
    // MARK: - actions
    @objc
    private func didTapTab(sender: UIButton) {
        setTabAndPage(to: sender.tag)
    }
    
    @objc
    private func didTapCloseButton() {
        dismiss(animated: true)
    }
    
    @objc
    private func switchTab(noti: Notification) {
        if let type = noti.object as? ChatMessageViewController.MessageType {
            let destTab: Tabs = {
                switch type {
                case .channel(_): return .channel
                case .dm(_, _):   return .message
                case .support:    return .support
                }
            }()
            setTabAndPage(to: destTab.rawValue)
            // wait unless animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                if let nav = self?.vcs[safe: destTab.rawValue] as? UINavigationController {
                    (nav.viewControllers.first as? ChatTabTogglable)?.didSetThenShow(type: type)
                }
            }
        }
    }
}

// only in use when AllowSwipePaging = true
extension ChatListContainerViewController: UIPageViewControllerDataSource {
    // MARK: UIPageViewControllerDataSource
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = vcs.firstIndex(of: viewController) {
            if index == 0 { return vcs.last }
            return vcs[index - 1]
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = vcs.firstIndex(of: viewController) {
            if index + 1 == vcs.count { return vcs[0] }
            return vcs[index + 1]
        }
        return nil
    }
}

// only in use when AllowSwipePaging = true
extension ChatListContainerViewController: UIPageViewControllerDelegate {
    // MARK: UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let last = pageVC.viewControllers?.first, let index = vcs.firstIndex(of: last) {
            setTab(to: index)
            currentPageIndex = index
        }
    }
}
