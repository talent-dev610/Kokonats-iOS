////  SessionResult.swift
//  kokonats
//
//  Created by sean on 2022/01/24.
//  
//

import Foundation

struct SessionResult: Codable {
    let matchId: String
    let users: [SessionUserInfo]
}

struct SessionUserInfo: Codable {
    let username: String
    let picture: String
    let subscriber: String
}

