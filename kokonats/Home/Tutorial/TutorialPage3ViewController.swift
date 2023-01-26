//
//  TutorialPage3ViewController.swift
//  kokonats
//
//  Created by George on 2022-05-03.
//

import Foundation
import UIKit

class TutorialPage3ViewController: UIViewController {
    override func viewDidLoad() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        let imageView = UIImageView()
        view.addSubview(imageView)
        imageView.image = UIImage(named: "tutorial_bg_3.png")
        imageView.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width * 0.8, height: self.view.frame.height * 0.7)
        imageView.backgroundColor = UIColor.white
        imageView.layer.cornerRadius = 20
        imageView.layer.borderWidth = 0.1
        imageView.layer.borderColor = UIColor.gray.cgColor
        
        let iconView = UIImageView()
        view.addSubview(iconView)
        iconView.image = UIImage(named: "tutorial_icon_3.png")?.scale(to: CGSize(width: 150, height: 120))
        iconView.activeConstraints(to: view, directions: [.centerX, .top(.top, 60)])
        
        let contentView = UILabel.formatedLabel(size: 20, text: "tutorial_content_3".localized, type: .bold, textAlignment: .center)
        view.addSubview(contentView)
        contentView.textColor = .black
        contentView.numberOfLines = 2
        contentView.activeConstraints(to: iconView, directions: [.centerX, .top(.bottom, 30)])
        
        let startView = UILabel.formatedLabel(size: 20, text: "tutorial_tap_start".localized, type: .bold, textAlignment: .center)
        view.addSubview(startView)
        startView.textColor = UIColor.selectedColor
        startView.numberOfLines = 1
        startView.activeConstraints(to: contentView, directions: [.centerX, .top(.bottom, 30)])
        let tapView = UITapGestureRecognizer(target: self, action: #selector(self.tapToStart))
        startView.isUserInteractionEnabled = true
        startView.addGestureRecognizer(tapView)
    }
    
    @objc func tapToStart() {
        let nc = NotificationCenter.default
        nc.post(name: NSNotification.Name(rawValue: "tapToStart"), object: nil)
    }
}
