//
//  BlockedUser.swift
//  kokonats
//
//  Created by smartdev0126 on 6/7/22.
//

import Foundation
struct BlockedUsers: Codable {
    let blockedUsers: [BlockedUser]
}
struct BlockedUser: Codable {
    let id: Int
    let username: String
    let picture: String
    let subscriber: String
    let createTime: Int
}

