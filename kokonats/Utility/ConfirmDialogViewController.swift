//
//  ConfirmDialogViewController.swift
//  kokonats
//
//  Created by George on 5/16/22.
//

import Foundation
import UIKit

enum ConfirmDialogType {
    case close
    case info
    case attention
    case question
    case lamp

    var icon: UIImage {
        switch self {
        case .close:
            return UIImage(named: "dlg_ic_close")!
        case .info:
            return UIImage(named: "dlg_ic_info")!
        case .attention:
            return UIImage(named: "dlg_ic_attention")!
        case .question:
            return UIImage(named: "dlg_ic_question")!
        case .lamp:
            return UIImage(named: "dlg_ic_lamp")!
        }
    }
}


class ConfirmDialogViewController: UIViewController {
    
    private var type: ConfirmDialogType!
    private var onOk: (() -> ())?
    private var onCancel: (() -> ())?
    private var dlgTitle: String!
    private var dlgContent: String!
    private var strOk: String!
    private var strCancel: String!
    
    private var dialogView: UIView!
    
    init(_ type: ConfirmDialogType, title: String, message: String, textOk: String, textCancel: String, onOk: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        self.type = type
        self.dlgTitle = title
        self.dlgContent = message
        self.strOk = textOk
        self.strCancel = textCancel
        self.onOk = onOk
        self.onCancel = onCancel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        dialogView = UIView()
        view.addSubview(dialogView)
        let dlgX = (self.view.frame.width - 295) / 2
        let dlgY = (self.view.frame.height - 295) / 2 - 30
        dialogView.frame = CGRect(x: dlgX, y: dlgY, width: 295, height: 295)
        dialogView.backgroundColor = UIColor.white
        dialogView.layer.cornerRadius = 10
        dialogView.layer.borderWidth = 0.1
        dialogView.layer.borderColor = UIColor.gray.cgColor
        
        let iconView = UIImageView()
        dialogView.addSubview(iconView)
        iconView.image = self.type.icon
        iconView.activeSelfConstrains([.width(50), .height(50)])
        iconView.activeConstraints(directions: [.centerX, .top(.top, 36)])
        
        let titleView = UILabel.formatedLabel(size: 20, text: self.dlgTitle, type: .bold, textAlignment: .center)
        dialogView.addSubview(titleView)
        titleView.textColor = .black
        titleView.numberOfLines = 0
        titleView.activeConstraints(directions: [.leading(.leading, 20), .trailing(.trailing, -20)])
        titleView.activeConstraints(to: iconView, directions: [.centerX, .top(.bottom, 30)])
        
        let messageView = UILabel.formatedLabel(size: 14, text: self.dlgContent, textAlignment: .center)
        dialogView.addSubview(messageView)
        messageView.textColor = .black
        messageView.numberOfLines = 0
        messageView.activeConstraints(directions: [.leading(.leading, 20), .trailing(.trailing, -20)])
        messageView.activeConstraints(to: titleView, directions: [.centerX, .top(.bottom, 10)])
        
        let backButton = UIButton()
        dialogView.addSubview(backButton)
        backButton.setTitle(self.strCancel, for: .normal)
        backButton.setTitleColor(.white, for: .normal)
        backButton.backgroundColor = .lightBgColor
        backButton.cornerRadius = 10
        backButton.activeConstraints(directions: [.leading(.leading, 40), .bottom(.bottom, -30)])
        backButton.activeSelfConstrains([.height(48), .width(100)])
        backButton.addTarget(self, action: #selector(onCancelClicked(_:)), for: .touchUpInside)
        
        let okButton = UIButton()
        dialogView.addSubview(okButton)
        okButton.setTitle(self.strOk, for: .normal)
        okButton.setTitleColor(.white, for: .normal)
        okButton.cornerRadius = 10
        okButton.activeConstraints(directions: [.trailing(.trailing, -40), .bottom(.bottom, -30)])
        okButton.activeSelfConstrains([.height(48), .width(100)])
        okButton.addTarget(self, action: #selector(onOkClicked(_:)), for: .touchUpInside)
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: 100, height: 48)
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.colors = [UIColor.bannerBlue.cgColor, UIColor.bannerPurple.cgColor]
        okButton.layer.insertSublayer(gradientLayer, at: 0)
        okButton.clipsToBounds = true
    }
    
    @objc func onCancelClicked(_ sender: UIButton) {
        self.dismiss(animated: false)
        (self.onCancel ?? {})()
    }
    
    @objc func onOkClicked(_ sender: UIButton) {
        self.dismiss(animated: false)
        (self.onOk ?? {})()
    }
}
