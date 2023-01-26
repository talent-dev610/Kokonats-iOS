////  MatchingUser.swift
//  kokonats
//
//  Created by sean on 2022/02/05.
//  
//

import Foundation


/// Users are matching but have not started playing yet.
struct MatchingUser: Codable {
    let userName: String
    let subscriber: String
    let picture: Int
    let locale: String
}

