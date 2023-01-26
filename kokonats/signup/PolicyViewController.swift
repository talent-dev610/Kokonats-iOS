//
//  PolicyViewController.swift
//  kokonats
//
//  Created by Andrei Yakugov on 6/3/22.
//

import Foundation
import UIKit
import WebKit

class PolicyViewController: UIViewController, WKUIDelegate {

    var vctitle = ""
    var vcurl = ""
    private var webView = WKWebView(frame: CGRect.zero, configuration: WKWebViewConfiguration())

    override func loadView() {
        view = UIView()
        view.backgroundColor = .white
        
        let button = UIButton()
        button.setImage(UIImage(named: "navigation"), for: .normal)
        view.addSubview(button)
        button.activeConstraints(to: view.safeAreaLayoutGuide, anchorDirections: [.leading(.leading, 20), .top(.top, 23)])
        button.activeSelfConstrains([.height(48), .width(48)])
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(self.closeAction), for: .touchUpInside)
        
        let vct = UILabel()
        view.addSubview(vct)
        vct.text = vctitle
        vct.textColor = hexStringToUIColor(hex: "#191A32")
        vct.font = .systemFont(ofSize: 16, weight: .bold)
        vct.activeConstraints(directions: [.top(.top, 35), .leading(.leading, 78)])
        

        
    }
    @objc private func closeAction() {
        dismiss(animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // set the delegate for webView
            webView.uiDelegate = self

            // define URL
            let myURL = URL(string: vcurl)

            // create request
            let myRequest = URLRequest(url: myURL!)

            // show request
            webView.load(myRequest)

            // make webView ready for Autolayout
            webView.translatesAutoresizingMaskIntoConstraints = false

            // add webView to view
            view.addSubview(webView)

            // size the webView beeing 75 % of the screen
            webView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            webView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        webView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIScreen.main.bounds.size.height * 0.1).isActive = true
        webView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.9).isActive = true
            
        
    }
    func hexStringToUIColor (hex:String) -> UIColor {
        var cString:String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }

        if ((cString.count) != 6) {
            return UIColor.gray
        }

        var rgbValue:UInt64 = 0
        Scanner(string: cString).scanHexInt64(&rgbValue)

        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
}
