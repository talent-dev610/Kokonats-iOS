//
//  TutorialDialogController.swift
//  kokonats
//
//  Created by George on 5/3/22.
//

import Foundation
import UIKit
import SwiftUI

class TutorialDialogController: UIViewController, TutorialPageControllerDataSource, TutorialPageControllerDelegate {
    
    
    private var dialogView: UIView!
    private var pageController: TutorialPageController?
    private var btnPrev: UIButton!
    private var btnNext: UIButton!
    private var txtPage: UILabel!
    private var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        dialogView = UIView()
        view.addSubview(dialogView)
        dialogView.frame = CGRect(x: self.view.frame.width * 0.1 , y: self.view.frame.height * 0.15, width: self.view.frame.width * 0.8, height: self.view.frame.height * 0.7)
        dialogView.backgroundColor = UIColor.white
        dialogView.layer.cornerRadius = 20
        dialogView.layer.borderWidth = 0.1
        dialogView.layer.borderColor = UIColor.gray.cgColor
        
        let pageViewController = TutorialPageController()
        pageController?.dataSource = self
        pageController?.delegate = self
        let currentViewController = self.pageViewController(at: 0)!
        pageViewController.selectViewController(currentViewController, direction: .forward, animated: false, completion: nil)
        self.addChild(pageViewController)
        dialogView.insertSubview(pageViewController.view, at: 0)
        pageViewController.didMove(toParent: self)
        self.pageController = pageViewController
        
        txtPage = UILabel.formatedLabel(size: 16, text: "1/3", type: .bold, textAlignment: .center)
        view.addSubview(txtPage)
        txtPage.font = .getKokoFont(type: .medium, size: 17)
        txtPage.textColor = UIColor.black
        txtPage.activeConstraints(to: self.view, directions: [.centerX, .bottom(.bottom, -(self.view.frame.height * 0.15 + 50))])
        
        btnPrev = UIButton()
        view.addSubview(btnPrev)
        btnPrev.activeSelfConstrains([.width(40), .height(40)])
        btnPrev.activeConstraints(to: self.view, directions: [.leading(.leading, self.view.frame.width * 0.1 + 20), .bottom(.bottom, -(self.view.frame.height * 0.15 + 40))])
        btnPrev.setImage(UIImage(named: "arrow_left.png"), for: .normal)
        btnPrev.addTarget(self, action: #selector(self.onPrev), for: .touchUpInside)
        
        btnNext = UIButton()
        view.addSubview(btnNext)
        btnNext.activeSelfConstrains([.width(40), .height(40)])
        btnNext.activeConstraints(to: self.view, directions: [.trailing(.trailing, -(self.view.frame.width * 0.1 + 20)), .bottom(.bottom, -(self.view.frame.height * 0.15 + 40))])
        btnNext.setImage(UIImage(named: "arrow_right.png"), for: .normal)
        btnNext.addTarget(self, action: #selector(self.onNext), for: .touchUpInside)
        
        setupPagination()
        
        let nc = NotificationCenter.default
        nc.addObserver(forName: NSNotification.Name(rawValue: "tapToStart"), object: nil, queue: nil, using: self.tapToStart(notification:))
    }
    
    @objc func onNext() {
        self.currentPage += 1
        setupPagination()
        self.pageController!.selectViewController(self.pageViewController(at: self.currentPage)!, direction: .forward, animated: false, completion: nil)
    }
    
    @objc func onPrev() {
        self.currentPage -= 1
        setupPagination()
        self.pageController!.selectViewController(self.pageViewController(at: self.currentPage)!, direction: .reverse, animated: false, completion: nil)
    }
    
    @objc func tapToStart(notification: Notification) {
        dismiss(animated: true)
    }
    
    @objc func setupPagination() {
        txtPage.text = (self.currentPage + 1).formatedString() + "/3"
        if currentPage > 0 {
            btnPrev.isHidden = false
        } else {
            btnPrev.isHidden = true
        }
        if currentPage < 2 {
            btnNext.isHidden = false
        } else {
            btnNext.isHidden = true
        }
    }
    
    func pageViewController(at index: Int) -> UIViewController? {
        if index == 0 {
            return TutorialPage1ViewController()
        } else if index == 1 {
            return TutorialPage2ViewController()
        } else {
            return TutorialPage3ViewController()
        }
    }
    
    // MARK: - TutorialPageController Data Source
    
    func tutorialPageViewController(_ pageViewController: TutorialPageController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if currentPage > 0 {
            return self.pageViewController(at: self.currentPage - 1)
        } else {
            return nil
        }
    }
    
    func tutorialPageViewController(_ pageViewController: TutorialPageController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if currentPage < 2 {
            return self.pageViewController(at: self.currentPage + 1)
        } else {
            return nil
        }
    }
}
