//
//  EditProfileViewController.swift
//  kokonats
//
//  Created by Mac on 4/10/22.
//

import UIKit

class EditProfileViewController: UIViewController {
    
    public var user: UserInfo?
    private var iconView: UIImageView!
    private var uidLabel: UILabel!
    private var userNameField: UITextField!
    private var selectedPhoto: Int = 5
    private var avatar1: UIImageView!
    private var avatar2: UIImageView!
    private var avatar3: UIImageView!
    private var avatar4: UIImageView!
    private var avatar5: UIImageView!
    private var avatarImages = [UIImageView]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLayout()
    }
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        setUserInfo()
    }
    

    func configureLayout() {
        
        view.backgroundColor = .kokoBgColor
        
        let backButton = UIButton()
        view.addSubview(backButton)
        backButton.activeConstraints(to: view, directions: [.leading(.leading, 40), .top(.top, 40)])
        backButton.activeSelfConstrains([.height(40), .width(40)])
        backButton.setImage(UIImage(named: "back"), for: .normal)
        backButton.addTarget(self, action: #selector(goBack(_:)), for: .touchUpInside)
        
        iconView = UIImageView()
        iconView.backgroundColor = .kokoBgColor
        view.addSubview(iconView)
        iconView.activeConstraints(to: view, directions: [.top(.top, 100), .centerX])
        iconView.widthAnchor.constraint(equalToConstant: 90).isActive = true
        iconView.heightAnchor.constraint(equalToConstant: 90).isActive = true
        iconView.cornerRadius = 45
        
        uidLabel = UILabel.formatedLabel(size: 12)
        view.addSubview(uidLabel)
        uidLabel.activeConstraints(to: view, directions: [.centerX, .leading(), .trailing()])
        uidLabel.activeConstraints(to: iconView, directions: [.top(.bottom, 21)])
        uidLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true

        userNameField = UITextField()
        userNameField.textColor = .white
        userNameField.layer.cornerRadius = 20
        userNameField.layer.borderColor = UIColor.lightGray.cgColor
        userNameField.layer.borderWidth = 1
        userNameField.textAlignment = .center
        userNameField.font = UIFont(name: UIFont.kokoFontType.regular.rawValue, size: 20)
        view.addSubview(userNameField)
        userNameField.activeConstraints(to: view, directions: [.centerX, .leading(.leading, 60)])
        userNameField.activeConstraints(to: uidLabel, directions: [.top(.bottom, 100)])
        userNameField.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        
        let kokoBg = UIView()
        kokoBg.backgroundColor = .clear
        view.addSubview(kokoBg)
        kokoBg.activeSelfConstrains([.height(60)])
        kokoBg.activeConstraints(to: view, directions: [.leading(.leading, 24), .centerX])
        kokoBg.activeConstraints(to: uidLabel, directions: [.top(.bottom, 16)])

        let iconContainer = UIView()
        iconContainer.backgroundColor = .clear
        view.addSubview(iconContainer)
        iconContainer.activeConstraints(to: kokoBg, directions: [.top(), .bottom(), .centerX])

        avatar3 = UIImageView(image: UIImage(named: "avatar3"))
        kokoBg.addSubview(avatar3)
        avatar3.activeConstraints(to: iconContainer, directions: [.centerX, .centerY])
        avatar3.activeSelfConstrains([.height(60), .width(60)])
        avatar3.cornerRadius = 30
        //avatar3.backgroundColor = .profilePhotoBgs[2]
        
        let avatar3Button = UIButton()
        avatar3Button.backgroundColor = .clear
        avatar3Button.tag = 3
        kokoBg.addSubview(avatar3Button)
        avatar3Button.activeConstraints(to: avatar3, directions: [.leading(), .top(), .trailing(), .bottom()])
        avatar3Button.addTarget(self, action: #selector(photoTapped(_:)), for: .touchUpInside)
        
        avatar2 = UIImageView(image: UIImage(named: "avatar2"))
        kokoBg.addSubview(avatar2)
        avatar2.activeConstraints(to: avatar3, directions: [.trailing(.leading, -10), .centerY])
        avatar2.activeSelfConstrains([.height(60), .width(60)])
        avatar2.cornerRadius = 30
        //avatar2.backgroundColor = .profilePhotoBgs[1]
        
        let avatar2Button = UIButton()
        avatar2Button.backgroundColor = .clear
        avatar2Button.tag = 2
        kokoBg.addSubview(avatar2Button)
        avatar2Button.activeConstraints(to: avatar2, directions: [.leading(), .top(), .trailing(), .bottom()])
        avatar2Button.addTarget(self, action: #selector(photoTapped(_:)), for: .touchUpInside)
        
        
        avatar1 = UIImageView(image: UIImage(named: "avatar1"))
        kokoBg.addSubview(avatar1)
        avatar1.activeConstraints(to: avatar2, directions: [.trailing(.leading, -10), .centerY])
        avatar1.activeSelfConstrains([.height(60), .width(60)])
        avatar1.cornerRadius = 30
        //avatar1.backgroundColor = .profilePhotoBgs[0]
        
        let avatar1Button = UIButton()
        avatar1Button.backgroundColor = .clear
        avatar1Button.tag = 1
        kokoBg.addSubview(avatar1Button)
        avatar1Button.activeConstraints(to: avatar1, directions: [.leading(), .top(), .trailing(), .bottom()])
        avatar1Button.addTarget(self, action: #selector(photoTapped(_:)), for: .touchUpInside)
        
        
        avatar4 = UIImageView(image: UIImage(named: "avatar4"))
        kokoBg.addSubview(avatar4)
        avatar4.activeConstraints(to: avatar3, directions: [.leading(.trailing, 10), .centerY])
        avatar4.activeSelfConstrains([.height(60), .width(60)])
        avatar4.cornerRadius = 30
        //avatar4.backgroundColor = .profilePhotoBgs[3]

        let avatar4Button = UIButton()
        avatar4Button.backgroundColor = .clear
        avatar4Button.tag = 4
        kokoBg.addSubview(avatar4Button)
        avatar4Button.activeConstraints(to: avatar4, directions: [.leading(), .top(), .trailing(), .bottom()])
        avatar4Button.addTarget(self, action: #selector(photoTapped(_:)), for: .touchUpInside)
        
        
        avatar5 = UIImageView(image: UIImage(named: "avatar5"))
        kokoBg.addSubview(avatar5)
        avatar5.activeConstraints(to: avatar4, directions: [.leading(.trailing, 10), .centerY])
        avatar5.activeSelfConstrains([.height(60), .width(60)])
        avatar5.cornerRadius = 30
        //avatar5.backgroundColor = .profilePhotoBgs[4]

        let avatar5Button = UIButton()
        avatar5Button.backgroundColor = .clear
        avatar5Button.tag = 5
        kokoBg.addSubview(avatar5Button)
        avatar5Button.activeConstraints(to: avatar5, directions: [.leading(), .top(), .trailing(), .bottom()])
        avatar5Button.addTarget(self, action: #selector(photoTapped(_:)), for: .touchUpInside)
        
        
        
        let okButton = UIImageView(image: UIImage(named: "play_again"))
        okButton.contentMode = .scaleAspectFit
        let okTapGR = UITapGestureRecognizer(target: self, action: #selector(okTapped(_:)))
        let playAgainLabel = UILabel.formatedLabel(size: 14, text: "user_logout_ok".localized, type: .black, textAlignment: .center)
        okButton.addSubview(playAgainLabel)
        playAgainLabel.activeConstraints()
        okButton.isUserInteractionEnabled = true
        okButton.addGestureRecognizer(okTapGR)
        view.addSubview(okButton)
        okButton.activeConstraints(to: kokoBg, directions: [.top(.bottom, 150), .centerX])
        okButton.activeSelfConstrains([.width(135), .height(48)])
        
        avatarImages.append(avatar1)
        avatarImages.append(avatar2)
        avatarImages.append(avatar3)
        avatarImages.append(avatar4)
        avatarImages.append(avatar5)
        
    }
    
    func setUserInfo() {
        guard let user = user else { return }
        userNameField.text = user.userName
        uidLabel.text = String(user.id)
        iconView.image = UIImage(named: "avatar_\(user.picture ?? "5")")
        avatarImages[Int(user.picture ?? "5")! - 1].backgroundColor = .profilePhotoBgs[Int(user.picture ?? "5")!]
        
    }
    
    @objc func goBack(_ sender: UIButton) {
        
        self.dismiss(animated: false)
        
    }
    
    @objc func photoTapped(_ sender : UIButton) {
        selectedPhoto = sender.tag
        avatarImages.forEach{ ($0.backgroundColor = .clear) }
        iconView.image = UIImage(named: "avatar_\(selectedPhoto)")
        avatarImages[selectedPhoto-1].backgroundColor = .profilePhotoBgs[selectedPhoto]
    }
    
    @objc func okTapped(_ sender: UIButton) {
        
        if userNameField.text!.isEmpty {
            return
        }
        ApiManager.shared.checkUsernameExist(idToken: LocalStorageManager.idToken, username: userNameField.text!) {result in
            switch result {
            case .success(let isValid):
                guard isValid else {
                    self.dismiss(animated: false)
                    self.showAlertDialog(title: "Invalid Username", message: "Username is duplicated or invalid", textOk: "OK")
                    return
                }
                ApiManager.shared.editProfile(idToken: LocalStorageManager.idToken, userName: self.userNameField.text!, picture: self.selectedPhoto) { result in

                    switch result {
                    case .success(_):
                        self.dismiss(animated: false)
                    case .failure(let error):
                        Logger.debug(error.localizedDescription)
                    }
                }
            case .failure(_):
                Logger.debug("Error")
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }

}
