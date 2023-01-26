////  KokoAlertViewController.swift
//  kokonats
//
//  Created by sean on 2022/01/15.
//  
//

import Foundation
import UIKit


class kokoAlertViewController: UIViewController {
    static let identifier = ""
    //MARK:- outlets for the viewController
    @IBOutlet weak var dialogBoxView: UIView!
    @IBOutlet weak var okayButton: UIImageView!
    @IBOutlet weak var backButton: UIImageView!
    //MARK:- lifeCycle methods for the view controller
    override func viewDidLoad(){
        super.viewDidLoad()
        //adding an overlay to the view to give focus to the dialog box
        view.backgroundColor = UIColor.black.withAlphaComponent(0.50)
        //customizing the dialog box view
        dialogBoxView.layer.cornerRadius = 6.0
        dialogBoxView.layer.borderWidth = 1.2
        //customizing the okay button
        
        backButton = UIImageView(image: UIImage(named: "tournament_entryfee_back"))
        backButton.layer.cornerRadius = 4.0
        backButton.layer.borderWidth = 1.2

        
        okayButton = UIImageView(image: UIImage(named: "tournament_entryfee_back"))
        okayButton.layer.cornerRadius = 4.0
        okayButton.layer.borderWidth = 1.2
    }
    //MARK:- outlet functions for the viewController
    @IBAction func okayButtonPressed(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    @IBAction func backButtonPressed(_ sender: Any) {
         self.dismiss(animated: true, completion: nil)
    }
    //MARK:- functions for the viewController
    static func showPopup(parentVC: UIViewController){
        //creating a reference for the dialogView controller
        if let popupViewController = UIStoryboard(name: "CustomView", bundle: nil).instantiateViewController(withIdentifier: "kokoAlertViewController") as? kokoAlertViewController {
        popupViewController.modalPresentationStyle = .custom
        popupViewController.modalTransitionStyle = .crossDissolve
        //presenting the pop up viewController from the parent viewController
        parentVC.present(popupViewController, animated: true)
        }
      }
}



