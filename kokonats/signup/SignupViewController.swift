////  SignupViewController.swift
//  kokonats
//
//  Created by sean on 2021/10/07.
//  
//

import UIKit
import AuthenticationServices
import CryptoKit
import FirebaseAuth
import Firebase
import GoogleSignIn

let twitterProvider = OAuthProvider(providerID: "twitter.com")
final class SignupViewController: UIViewController {

    enum SignUpActionType {
        case apple
        case google
        case twitter
    }

    static var shared = SignupViewController()

    // Unhashed nonce.
    private var currentNonce: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
    }

    private func configure() {
        let signupView = SignupView()
        view.backgroundColor = .kokoBgColor
        view.addSubview(signupView)
        signupView.activeConstraints(to: view.safeAreaLayoutGuide, anchorDirections: [.top(), .leading(), .bottom(), .trailing()])
        signupView.eventHandler = self
    }

    private func signInWithApple() {
        let nonce = SignInWithAppleHelper.randomNonceString()
        currentNonce = nonce

        let request = ASAuthorizationAppleIDProvider().createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = SignInWithAppleHelper.sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }

    private func signInWithGoogle() {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)

        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [weak self] user, error in
            if let user = user, error == nil {
                guard
                    let idToken = user.authentication.idToken
                  else {
                    return
                  }
                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                               accessToken: user.authentication.accessToken)
                LocalStorageManager.idToken = idToken
                LocalStorageManager.googleUserId = user.userID ?? ""
                LocalStorageManager.fullName = user.profile?.name ?? ""
                LocalStorageManager.email = user.profile?.email ?? ""
                self?.authenticateWithFirebase(credential: credential, idToken: idToken, type: .google)
            } else{
                Logger.debug("debug " + error.debugDescription)
            }
        }
    }
    
    private func signInWithTwitter() {
        twitterProvider.getCredentialWith(nil) { credential, error in
              if error != nil {
              }
              if credential != nil {
                  self.authenticateWithFirebase(credential: credential!, idToken: "", type: .twitter)
              }
            }
    }
    
    
    private func authenticateWithFirebase(credential: AuthCredential, idToken: String, type: LoginType) {
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
                  let authError = error as NSError
                  if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                    let resolver = authError
                      .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                    var displayNameString = ""
                    for tmpFactorInfo in resolver.hints {
                      displayNameString += tmpFactorInfo.displayName ?? ""
                      displayNameString += " "
                    }
                    self.showTextInputPrompt(
                      withMessage: "Select factor to sign in\n\(displayNameString)",
                      completionBlock: { userPressedOK, displayName in
                        var selectedHint: PhoneMultiFactorInfo?
                        for tmpFactorInfo in resolver.hints {
                          if displayName == tmpFactorInfo.displayName {
                            selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                          }
                        }
                        PhoneAuthProvider.provider()
                          .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                             multiFactorSession: resolver
                                               .session) { verificationID, error in
                            if error != nil {
                              print(
                                "Multi factor start sign in failed. Error: \(error.debugDescription)"
                              )
                            } else {
                              self.showTextInputPrompt(
                                withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                                completionBlock: { userPressedOK, verificationCode in
                                  let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                    .credential(withVerificationID: verificationID!,
                                                verificationCode: verificationCode!)
                                  let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                    .assertion(with: credential!)
                                  resolver.resolveSignIn(with: assertion!) { authResult, error in
                                    if error != nil {
                                      print(
                                        "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                      )
                                    } else {
                                      self.navigationController?.popViewController(animated: true)
                                    }
                                  }
                                }
                              )
                            }
                          }
                      }
                    )
                  } else {
                    self.showMessagePrompt(error.localizedDescription)
                    return
                  }
                  return
                }

            // NOTE: We are not sure, but need to do this.
            // ref: https://kokonatsinc.slack.com/archives/C03AVLJ4657/p1652497776953689?thread_ts=1652486275.916319&cid=C03AVLJ4657
            Auth.auth().currentUser?.getIDTokenForcingRefresh(true, completion: { newIdToken, error in
                if let newIdToken = newIdToken {
                    LocalStorageManager.idToken = newIdToken
                    self.handleLoginInfo(idToken: newIdToken, type: type)
                } else {
                    self.handleLoginInfo(idToken: idToken, type: type)
                }
            })
        }
    }

    private func handleLoginInfo(idToken: String, type: LoginType) {
        ApiManager.shared.loginToKoko(idToken: idToken, type: type) { result in
            switch result {
            case .success(let userInfo):
                AppData.shared.currentUser = userInfo
                NotificationCenter.default.post(name: .userLoggedIn, object: nil)
            default:
                break
            }
        }
    }
}

protocol SignupEventHandler {
    func signupEvent(type: SignupViewController.SignUpActionType)
    func cancelEvent()
}

extension SignupViewController: SignupEventHandler {
    func signupEvent(type: SignUpActionType) {
        switch type {
            case .apple:
                signInWithApple()
            case .google:
                signInWithGoogle()
            case .twitter:
                signInWithTwitter()
        }
    }
    func cancelEvent() {
        NotificationCenter.default.post(name: .userCanceledLogin, object: nil)
    }
}


// MARK: extension for sign in with apple

extension SignupViewController: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard currentNonce != nil else {
                Logger.debug("Invalid state: A login callback was received, but no login request was sent.")
                return
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
              Logger.debug("Unable to fetch identity token")
              return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                Logger.debug("Unable to serialize token string from data: \(appleIDToken.debugDescription)")
                    return
            }
            let userIdentifier = appleIDCredential.user
            LocalStorageManager.idToken = idTokenString
            LocalStorageManager.appleUserId = userIdentifier
            saveUserInKeychain(userIdentifier)

            LocalStorageManager.fullName = appleIDCredential.fullName?.description ?? ""
            LocalStorageManager.email = appleIDCredential.email ?? ""
            let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                      idToken: idTokenString,
                                                      rawNonce: currentNonce)

            self.authenticateWithFirebase(credential: credential, idToken: idTokenString, type: .apple)
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        Logger.debug(className + "." + #function + ": " + error.localizedDescription)
    }
}

extension SignupViewController: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}


// MARK: some helper function for saving cridential

extension SignupViewController {

    private func saveUserInKeychain(_ userIdentifier: String) {
        do {
            try KeychainItem(service: "com.biiiiit.club-kokonats", account: "userIdentifier").saveItem(userIdentifier)
        } catch {
            Logger.debug("Unable to save userIdentifier to keychain.")
        }
    }

    private func deleteUserInKeychain() {
        do {
            try KeychainItem(service: "com.biiiiit.club-kokonats", account: "userIdentifier").deleteItem()
        } catch {
            Logger.debug("failed to delete item")
        }
    }

    private func showPasswordCredentialAlert(username: String, password: String) {
        let message = "The app has received your selected credential from the keychain. \n\n Username: \(username)\n Password: \(password)"
        self.showAlertDialog(title: "Keychain Credential Received", message: message, textOk: "Dismiss")
    }
}

// MARK: some helper functions for firebase auth

extension SignupViewController {
    func showMessagePrompt(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: false, completion: nil)
      }

      func showTextInputPrompt(withMessage message: String,
                               completionBlock: @escaping ((Bool, String?) -> Void)) {
        let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
          completionBlock(false, nil)
        }
        weak var weakPrompt = prompt
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
          guard let text = weakPrompt?.textFields?.first?.text else { return }
          completionBlock(true, text)
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(cancelAction)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
      }
}
