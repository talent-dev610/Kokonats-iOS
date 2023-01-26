////  UserInfo.swift
//  kokonats
//
//  Created by sean on 2021/09/19.
//  
//

import Foundation

struct UserInfo {
    let id: Int
    let userName: String?
    let email: String?
    let emailVerified: Int
    let picture: String?
    let locale: String?
    let subscriber: String?

    init?(json: JSONObject) {
        guard let id = json["id"] as? Int else {
            return nil
        }
        self.id = id
        self.userName = json["userName"] as? String ?? ""
        self.email = json["email"] as? String ?? ""
        self.emailVerified = json["emailVerified"] as? Int ?? 0
        self.picture = json["picture"] as? String ?? ""
        self.locale = json["locale"] as? String ?? ""
        self.subscriber = json["subscriber"] as? String ?? ""
    }
}
