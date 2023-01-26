////  TabBar.swift
//  kokonats
//
//  Created by sean on 2021/12/02.
//  
//

import Foundation
import UIKit

enum TabBarType: String {
    case store
    case home
    case user

    var imageName: String {
        switch self {
        case .home:
            return "home_tab_icon"
        case .store:
            return "store_tab_icon"
        case .user:
            return "user_tab_icon"
        }
    }
}

class TabBarItem: UITabBarItem {
    init(type: TabBarType) {
        super.init()
        let icon = UIImage(named: type.imageName)?.scale(to: CGSize(width: 24, height: 24))
        image = icon
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIImage {
    func scale(to size: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
