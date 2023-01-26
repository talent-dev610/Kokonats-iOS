////  CollectionDataType.swift
//  kokonats
//
//  Created by sean on 2021/09/27.
//  
//

import UIKit

enum CollectionDataType {
    case tournamentList([TournamentClassDetail])
    case gameList([GameDetail])
    case matches([GameMatch])

    var dataCount: Int {
        switch self {
        case .tournamentList(let list):
            return list.count
        case .gameList(let list):
            return list.count
        case .matches(let list):
            return list.count
        }
    }

    var size: CGSize {
        switch self {
        case .tournamentList, .matches:
            return CGSize(width: 295, height: 360)
        case .gameList:
            return CGSize(width: 255, height: 188)
        }
    }

    func filteredDataList(tag: String) -> CollectionDataType {
        switch self {
        case .tournamentList(let list):
            let filteredList = list.filter{ $0.tags.contains(tag) }
            return .tournamentList(filteredList)
        case .gameList(let list):
            let filteredList = list.filter { $0.category == tag }
            return .gameList(filteredList)
        case .matches(let list):
            return .matches(list)
        }
    }
}
