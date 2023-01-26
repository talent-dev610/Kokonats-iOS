////  SignupView.swift
//  kokonats
//
//  Created by sean on 2021/10/07.
//  
//

import UIKit
import AuthenticationServices
import GoogleSignIn

final class SignupView: UIView {

    private var googleSignupView, twitterSignupView: UIImageView!
    //private var appleSignupButton: ASAuthorizationAppleIDButton!
    private var appleSignupButton: UIButton!
    private var privacyLabel: UILabel!
    var eventHandler: SignupEventHandler?
    let lblTerms = UILabel()

    var tu = ""
    var pp = ""
    var text = ""
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .kokoBgColor
        // FIXME: replace close icon
        let closeButton = UIButton(type: .close)
        addSubview(closeButton)
        closeButton.activeConstraints(directions: [.top(.top, 24), .leading(.leading, 12)])
        closeButton.activeSelfConstrains([.width(30), .height(30)])
        closeButton.addTarget(self, action: #selector(self.closeAction), for: .touchUpInside)
      
        let kokoLogo = UIImageView(image: UIImage(named: "new_k_log"))
        addSubview(kokoLogo)
        kokoLogo.activeConstraints(directions: [.top(.top, 88), .centerX])
        kokoLogo.activeSelfConstrains([.width(87), .height(90)])
        let descriptionLabel = UILabel.formatedLabel(size: 28, text: "アカウント作成")
        addSubview(descriptionLabel)
        descriptionLabel.activeConstraints(to: self, directions: [.centerX, .leading(), .trailing()])
        descriptionLabel.activeConstraints(to: kokoLogo, directions: [.top(.bottom, 55)])
        descriptionLabel.activeSelfConstrains([.height(38)])

        
        let customAppleLoginBtn = UIButton()
        addSubview(customAppleLoginBtn)
        customAppleLoginBtn.backgroundColor = UIColor.white
        customAppleLoginBtn.setImage(UIImage(named: "appleicon"), for: .normal)
        customAppleLoginBtn.setTitle("          Apple ID でサインインする", for: .normal)
        customAppleLoginBtn.setTitleColor(hexStringToUIColor(hex: "#191A32"), for: .normal)
        customAppleLoginBtn.titleLabel?.font = .systemFont(ofSize: 14.0, weight: .bold)
        customAppleLoginBtn.cornerRadius = 15.0
        customAppleLoginBtn.addTarget(self, action: #selector(signInWithAppleAction), for: .touchUpInside)
        customAppleLoginBtn.activeConstraints(to: descriptionLabel, directions: [.top(.bottom, 51)])
        customAppleLoginBtn.activeConstraints(to: kokoLogo, directions: [.centerX])
        customAppleLoginBtn.activeSelfConstrains([.height(48), .width(295)])
        self.appleSignupButton = customAppleLoginBtn
        
        
        /*
        let appleSignupButton = ASAuthorizationAppleIDButton(authorizationButtonType: .signIn,
                                                               authorizationButtonStyle: .white)
        addSubview(appleSignupButton)
        appleSignupButton.activeConstraints(to: descriptionLabel, directions: [.top(.bottom, 51)])
        appleSignupButton.activeConstraints(to: kokoLogo, directions: [.centerX])
        appleSignupButton.activeSelfConstrains([.height(48), .width(295)])
        appleSignupButton.addTarget(self, action: #selector(signInWithAppleAction), for: .touchUpInside)
        self.appleSignupButton = appleSignupButton
         */
        
        
        let googleSignup = UIImageView(image: UIImage(named: "google_signup"))
        addSubview(googleSignup)
        googleSignup.activeConstraints(to: appleSignupButton, directions: [.top(.bottom, 30)])
        googleSignup.activeConstraints(to: self, directions: [.leading(.leading, UIScreen.main.bounds.size.width / 2 - 83)])
        googleSignup.activeSelfConstrains([.height(68), .width(68)])
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(self.signInWithGoogleAction))
        googleSignup.addGestureRecognizer(tapGR)
        googleSignup.isUserInteractionEnabled = true
        self.googleSignupView = googleSignup
        
        let twitterSignup = UIImageView(image: UIImage(named: "twitter_signup"))
        addSubview(twitterSignup)
        twitterSignup.activeConstraints(to: appleSignupButton, directions: [.top(.bottom, 30)])
        twitterSignup.activeConstraints(to: self, directions: [.trailing(.trailing, -(UIScreen.main.bounds.size.width / 2 - 83))])
        twitterSignup.activeSelfConstrains([.height(68), .width(68)])
        let tiwtterGR = UITapGestureRecognizer(target: self, action: #selector(self.signInWithTwitterAction))
        twitterSignup.addGestureRecognizer(tiwtterGR)
        twitterSignup.isUserInteractionEnabled = true
        self.twitterSignupView = twitterSignup
        
        addSubview(lblTerms)
        if Locale.current.languageCode == "en" {
            tu = "Terms"
            pp = "Privacy policies"
            text = "By signing up, you agree with the \(tu) & \(pp)"
        } else {
            tu = "利用規約"
            pp = "プライバシーポリシー"
            text = "登録すると\(pp)と\(tu)に同意したものとみなします。"
        }
        
        lblTerms.text = text
        lblTerms.textColor = hexStringToUIColor(hex: "#7583CA")
        let underlineAttriString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: pp)
        let range2 = (text as NSString).range(of: tu)
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range1)
        
        underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range2)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range2)
        lblTerms.attributedText = underlineAttriString
        lblTerms.isUserInteractionEnabled = true
        lblTerms.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tapLabel(gesture:))))
        lblTerms.font = .systemFont(ofSize: 10.5, weight: .regular)
        lblTerms.activeConstraints(to: twitterSignupView, directions: [.top(.bottom, 238)])
        if Locale.current.languageCode == "en" {
            lblTerms.activeConstraints(to: self, directions: [.leading(.leading, (UIScreen.main.bounds.size.width / 2 - 145))])
        } else {
            lblTerms.activeConstraints(to: self, directions: [.leading(.leading, (UIScreen.main.bounds.size.width / 2 - 160))])
        }
        
        
        

    }
    @objc func tapLabel(gesture: UITapGestureRecognizer) {
        let termsRange = (text as NSString).range(of: tu)
        // comment for now
        let privacyRange = (text as NSString).range(of: pp)

        if gesture.didTapAttributedTextInLabel(label: lblTerms, inRange: termsRange) {
            presentPolicyView(ki: "1")
        } else if gesture.didTapAttributedTextInLabel(label: lblTerms, inRange: privacyRange) {
            presentPolicyView(ki: "2")
        }
    }
    private func presentPolicyView(ki: String) {
        let pvc = PolicyViewController()
        if ki == "1" {
            pvc.vctitle = "利用規約 / Terms of Service"
            pvc.vcurl = "https://game.kokonats.club/terms"
        } else if ki == "2" {
            pvc.vctitle = "プライバシーポリシー / Privacy Policy"
            pvc.vcurl = "https://game.kokonats.club/privacy"
        }

        UIApplication.topMostViewController?.present(pvc, animated: true, completion: nil)
    }
    @objc private func signInWithAppleAction() {
        eventHandler?.signupEvent(type: .apple)
    }

    @objc private func signInWithGoogleAction() {
        eventHandler?.signupEvent(type: .google)
    }
    
    @objc private func signInWithTwitterAction() {
        eventHandler?.signupEvent(type: .twitter)
    }
  
    @objc private func closeAction() {
        eventHandler?.cancelEvent()
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
extension UITapGestureRecognizer {

    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)

        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)

        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize

        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        //let textContainerOffset = CGPointMake((labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,
        //(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y);
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x, y: (labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)

        //let locationOfTouchInTextContainer = CGPointMake(locationOfTouchInLabel.x - textContainerOffset.x,
        // locationOfTouchInLabel.y - textContainerOffset.y);
        let locationOfTouchInTextContainer = CGPoint(x: locationOfTouchInLabel.x - textContainerOffset.x, y: locationOfTouchInLabel.y - textContainerOffset.y)
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
}
extension UIApplication {
    /// The top most view controller
    static var topMostViewController: UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController?.visibleViewController
    }
}
extension UIViewController {
    /// The visible view controller from a given view controller
    var visibleViewController: UIViewController? {
        if let navigationController = self as? UINavigationController {
            return navigationController.topViewController?.visibleViewController
        } else if let tabBarController = self as? UITabBarController {
            return tabBarController.selectedViewController?.visibleViewController
        } else if let presentedViewController = presentedViewController {
            return presentedViewController.visibleViewController
        } else {
            return self
        }
    }
}
