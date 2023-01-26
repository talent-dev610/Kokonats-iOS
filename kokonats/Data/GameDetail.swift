////  GameDetail.swift
//  kokonats
//
//  Created by sean on 2021/09/23.
//  
//

struct GameDetail: Codable {
    let id: Int
    let nid: String
    let name: String?
    let shortName: String?
    let category: String?
    let slogan: String?
    let description: String?
    let introduction: String?
    let iconUrl: String?
    let faviconUrl: String?
    let screenshot: String?
    let coverImageUrl: String?
    let email: String?
    let company: String?
    let twitter: String?
    let facebook: String?
    let line: String?
    let cdnUrl: String?
    let gameServerUrl: String?
    let callbackUrl: String?
    let state: Int?
    let highlightType: Int?
    let orderWeight: Int?
    let secret: String?
    let createTimestamp: Int?
}
