////  UserDefaultManager.swift
//  kokonats
//
//  Created by sean on 2021/09/19.
//  
//

import Foundation

enum UserDefaultKey: String {
    // TODO: should save it in keychain
    case idToken = "idToken"
    case userInfo = "userInfo"
    case email = "email"
    case fullName = "fullname"
    case userType = "userType"
    case appleUserId = "appleUserId"
    case googleUserId = "googleUserId"
    case isNotFirstRun = "isNotFirstRun"
}

enum UserType: String {
    case apple = "APPLE"
    case google = "GOOGLE"
}

final class LocalStorageManager {
    
    // TODO: reset all data
    func resetAll() {

    }

    static var idToken: String {
        get {
            let key = UserDefaultKey.idToken.rawValue
            return UserDefaults.standard.string(forKey: key) ?? ""
        }
        set {
            let key = UserDefaultKey.idToken.rawValue
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }

    static var appleUserId: String {
        get {
            let key = UserDefaultKey.appleUserId.rawValue
            return UserDefaults.standard.string(forKey: key) ?? ""
        }
        set {
            let key = UserDefaultKey.appleUserId.rawValue
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }
  
    static var googleUserId: String {
        get {
            let key = UserDefaultKey.googleUserId.rawValue
            return UserDefaults.standard.string(forKey: key) ?? ""
        }
        set {
            let key = UserDefaultKey.googleUserId.rawValue
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }

    static var email: String {
        get {
            let key = UserDefaultKey.email.rawValue
            return UserDefaults.standard.string(forKey: key) ?? ""
        }
        set {
            let key = UserDefaultKey.email.rawValue
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }

    static var fullName: String {
        get {
            let key = UserDefaultKey.fullName.rawValue
            return UserDefaults.standard.string(forKey: key) ?? ""
        }
        set {
            let key = UserDefaultKey.fullName.rawValue
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }

    static var userType: UserType? {
        get {
            let key = UserDefaultKey.userType.rawValue
            return UserType(rawValue: UserDefaults.standard.string(forKey: key) ?? "")
        }

        set {
            let key = UserDefaultKey.userType.rawValue
            newValue.flatMap {
                UserDefaults.standard.setValue($0.rawValue, forKey: key)
            }
        }
    }
    
    static var isNotFirstRun: Bool {
        get {
            let key = UserDefaultKey.isNotFirstRun.rawValue
            return UserDefaults.standard.bool(forKey: key)
        }

        set {
            let key = UserDefaultKey.isNotFirstRun.rawValue
            UserDefaults.standard.setValue(newValue, forKey: key)
        }
    }

    static func remove(key: UserDefaultKey) {
        UserDefaults.standard.set(nil, forKey: key.rawValue)
    }
}
