////  PlaygroundViewController.swift
//  kokonats
//
//  Created by sean on 2021/10/01.
//  
//

import WebKit
import UIKit

enum PlayType: String {
    case tournament
    case match
    case practise
}

struct RequestInfo {
    let gameAuth: String
    let playId: String
    let playType: PlayType
    let gameUrl: String
    let duration: Int

    func buildUrl() -> URL? {
        let idType: String = {
            switch playType {
            case .tournament, .practise:
                return "tournamentPlayId"
            case .match:
                return "matchPlayId"
            }
        }()
        let urlString: String = "\(gameUrl)?token=\(gameAuth)&\(idType)=\(playId)&playType=\(playType.rawValue)&durationSecond=\(duration)"
        Logger.debug(urlString)
        return URL(string: urlString)
    }
}

final class PlaygroundViewController: UIViewController, WKUIDelegate {
    var webView: WKWebView!
    var resultHandler: GameResultHandler?
    var requestInfo: RequestInfo!
    private var userInfo: UserInfo?
    private var shouldCheckState = false
    private var isGameOver: Bool = false

    override func loadView() {
        view = UIView()
        let webConfiguration = WKWebViewConfiguration()
        // NOTE: related to zooming.
        //       set false, to operate `user-scalable` from server.
        webConfiguration.ignoresViewportScaleLimits = false
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        view.addSubview(webView)
        constrainView(view: webView, toView: view)
        webView.configuration.userContentController.add(self, name: "playground")
        webView.uiDelegate = self
        webView.scrollView.delegate = self
        
    }
    func constrainView(view:UIView, toView contentView:UIView) {
        view.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 50).isActive = true
        view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50).isActive = true
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        AppData.shared.getCurrentUser { [weak self] userInfo in
            DispatchQueue.main.async {
                if let self = self,
                   let subscriberId: String = userInfo?.subscriber,
                    let url = self.requestInfo.buildUrl() {
                    let request = URLRequest(url: url)
                    self.webView.load(request)
                    self.shouldCheckState = true
                    self.checkingGameStatus(subscriberId: subscriberId)
                } else {
                    //TODO: show error message.
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
/*
    override func viewDidAppear(_ animated: Bool) {
        let screen = UIScreen.main.bounds
        let screenWidth = screen.size.width
        let screenHeight = screen.size.height - 30
        webView.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
    }
 */
    private func checkingGameStatus(subscriberId: String) {
        guard shouldCheckState else {
            return
        }
        switch requestInfo.playType {
        case .tournament:
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                FirestoreManager.shared.getState(collectionName: "dev-tournamentPlay",
                                                 documentId: "\(self.requestInfo.playId)_\(subscriberId)") { [weak self] state in
                    guard let state = state else {
                        self?.checkingGameStatus(subscriberId: subscriberId)
                        return
                    }
                    // which means game is stopped
                    if state == 1 {
                        self?.closeGameWebview()
                    } else {
                        self?.checkingGameStatus(subscriberId: subscriberId)
                        return
                    }
                }
            }

        case .match:
            DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
                let documentId = "\(self.requestInfo.playId)_\(subscriberId)"
                FirestoreManager.shared.getState(collectionName: "dev-matchPlay",
                                                 documentId: documentId) { [weak self] state in
                    guard let state = state else {
                        self?.checkingGameStatus(subscriberId: subscriberId)
                        return
                    }

                    // which means game is stopped
                    if state == 1 {
                        self?.closeGameWebview()
                    } else {
                        self?.checkingGameStatus(subscriberId: subscriberId)
                        return
                    }
                }
            }
        case .practise:
            break
        }
    }

    private func closeGameWebview() {
        shouldCheckState = false
        guard !isGameOver else { return }
        isGameOver = true
        dismiss(animated: true) { [self] in
            self.resultHandler?.handleEvent(.gameResult)
        }
    }
}

extension PlaygroundViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let json = message.body as? JSONObject else {
            return
        }
        if let closeGame = json["closeGame"] as? Bool, closeGame == true {
            self.dismiss(animated: true, completion: nil)
        }
    }

    func webViewDidClose(_ webView: WKWebView) {
        self.closeGameWebview()
    }
}

// koko does not permit to zoom webview by users
extension PlaygroundViewController: UIScrollViewDelegate {
    // won't be called.
    func viewForZooming(in scrollView: UIScrollView) -> UIView? { return nil }
    
    // NOTE: not sure but it seems to need to set disable every time.
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.pinchGestureRecognizer?.isEnabled = false
    }
}
