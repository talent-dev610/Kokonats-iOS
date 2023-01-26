//
//  MainViewController.swift
//  kokonats
//
//  Created by sean on 2021/07/12.
//

import UIKit
import Firebase
import AuthenticationServices

var usingDebuggingToken: Bool = false
var debug: Bool = true
var debugPurchasing: Bool = false
var debugSimulator: Bool = false
var usingLocalPage: Bool = true

class MainViewController: UITabBarController {
    var home = HomeViewController()
    var signupVC = SignupViewController()
//    var engergyStoreVC = StoreViewController()
    var engergyStoreVC = StoreNewViewController()
    var userProfileVC = UserProfileViewController()
    var backIndex: Int? = nil // to back to a vc when user canceled sign-in
    private var chatButton = UIButton(type: .custom)
    private var dotUnread = UIView()


    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .kokoBgColor
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogin), name: .userLoggedIn, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidCancelLogin), name: .userCanceledLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidLogout), name: .logout, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLoginScreen), name: .needLogin, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showEnergyStore), name: .showEnergyStore, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(registerFcmToken), name: .fcmTokenGenerated, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showUnreadDot), name: .refreshUnreadDMDot, object: nil)

        if debugSimulator {
            showMainUI()
            return
        }

        engergyStoreVC.tabBarItem = TabBarItem(type: .store)
        home.tabBarItem = TabBarItem(type: .home)
        userProfileVC.tabBarItem = TabBarItem(type: .user)
        setViewControllers([engergyStoreVC, home, userProfileVC], animated: false)
        view.backgroundColor = .kokoBgColor
        tabBar.isTranslucent = false
        tabBar.barTintColor = .kokoBgColor
        selectedIndex = 1
        
        // NOTE: chatButton is a floating button. make sure view hierarchy.
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.view.addSubview(self.chatButton)
            let tabHeight = self.tabBar.frame.height
            self.chatButton.activeSelfConstrains([.width(60), .height(60)])
            // tabBar 自体が safeAreaLayoutGauide の分を含んでいるため self.view を指定する
            self.chatButton.activeConstraints(to: self.view, directions: [.trailing(.trailing, -20), .bottom(.bottom, -(tabHeight + 10))])
            self.chatButton.setImage(UIImage(named: "chat_button"), for: .normal)
            self.chatButton.addTarget(self, action: #selector(self.didTapChatButton), for: .touchUpInside)
            
            self.view.addSubview(self.dotUnread)
            self.dotUnread.activeSelfConstrains([.width(20), .height(20)])
            self.dotUnread.activeConstraints(to: self.chatButton, directions: [.trailing(.trailing, 5), .top(.top, -5)])
            self.dotUnread.backgroundColor = .kokoYellow
            self.dotUnread.dropShadow(cornerRadius: 10)
            self.dotUnread.isHidden = true
            
            self.showTutorial()
        }
        
//        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: LocalStorageManager.appleUserId) { [weak self] (credentialState, error) in
//            showMainUI()
//            switch credentialState {
//            case .authorized where !LocalStorageManager.appleUserId.isEmpty:
//                DispatchQueue.main.async {
//                    SignupViewController.shared.performExistingAccountSetupFlows()
//
//                    self?.showMainUI()
//                }
//            default:
//                DispatchQueue.main.async {
//                    self?.showSignup()
//                }
//            }
//        }

        StoreManager.shared.fetchProductsIfNeeded()
    }

    private func showMainUI(selectedIndex: Int? = nil) {
        setViewControllers([engergyStoreVC, home, userProfileVC], animated: false)
        if let selectedIndex = selectedIndex {
            self.selectedIndex = selectedIndex
        }
    }

    @objc private func showEnergyStore() {
        DispatchQueue.main.async {
            self.selectedIndex = 0
        }
    }

    @objc private func userDidLogin() {
        self.registerFcmToken()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showMainUI(selectedIndex: 1)
            self.signupVC.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc private func registerFcmToken() {
        guard AppData.shared.isLoggedIn() else {
            return
        }
        ApiManager.shared.registerFCMToken(token: AppData.shared.fcmToken!) { result in
            switch result {
            case .success(let data):
                print("register fcm token")
                ChatManager.shared.fetchLastReadAt() {_ in
                    
                }
            case .failure(let error):
                Logger.debug(error.localizedDescription)
            }
        }
    }
    
    @objc private func showUnreadDot() {
        if AppData.shared.unreadThreads.isEmpty {
            self.dotUnread.isHidden = true
        } else {
            self.dotUnread.isHidden = false
        }
    }
    
    
   @objc private func showTutorial() {
       if LocalStorageManager.isNotFirstRun {
           return
       }
       LocalStorageManager.isNotFirstRun = true
       let toVC = TutorialDialogController()
      toVC.modalPresentationStyle = .custom
      toVC.modalTransitionStyle = .crossDissolve
       self.present(toVC, animated: true, completion: nil)
    }
    
    @objc private func userDidLogout() {
        AppData.shared.unreadThreads.removeAll()
        NotificationCenter.default.post(name: .refreshUnreadDMDot, object: nil)
        DispatchQueue.main.async {
            self.selectedIndex = 1
        }
    }
  
    @objc private func userDidCancelLogin() {
        DispatchQueue.main.async {
            self.backIndex.flatMap {
                self.selectedIndex = $0
            }
            self.signupVC.dismiss(animated: true, completion: nil)
        }
    }

    @objc private func showLoginScreen() {
        backIndex = selectedIndex
        DispatchQueue.main.async {
            self.showSignup()
        }
    }
    
    @objc
    private func didTapChatButton() {
        let chatListVC = ChatListContainerViewController()
        chatListVC.modalPresentationStyle = .overFullScreen
        show(chatListVC, sender: nil)
    }

    private func showSignup() {
        signupVC.modalPresentationStyle = .fullScreen
        self.selectedViewController?.show(signupVC, sender: self)
    }

    private func buildVC(from storyboardName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(storyboardName)ViewController")
    }
}

extension UIStoryboard {
    static func buildVC(from storyboardName: String) -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "\(storyboardName)ViewController")
    }
}

extension Notification.Name {
    static let userLoggedIn = Notification.Name("userLoggedIn")
    static let needLogin = Notification.Name("needLogin")
    static let logout = Notification.Name("logout")
    static let kokoPurchased = Notification.Name("kokoPurchased")
    static let failedPurchaseKoko = Notification.Name("failedPurchaseKoko")
    static let showEnergyStore = Notification.Name("showEnergyStore")
    static let userCanceledLogin = Notification.Name("userCanceledLogin")
    static let needToSwitchChatTab = Notification.Name("needToSwitchChatTab")
    static let fcmTokenGenerated = Notification.Name("fcmToken")
    static let refreshUnreadDMDot = Notification.Name("refreshUnreadDMDot")
    static let refreshUnreadDMDotTab = Notification.Name("refreshUnreadDMDotTab")
    static let refreshUnreadDMDotItem = Notification.Name("refreshUnreadDMDotItem")
}
