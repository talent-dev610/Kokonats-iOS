//
//  ViewControllerManager.swift
//  Qiafan
//
//  Created by  周轶飞 on 2020/01/18.
//  Copyright © 2020 qiafan.app. All rights reserved.
//

import UIKit

enum ViewController: String {
    case TournamentDetail

    var hasStoryboard: Bool {
        switch self {
        case .TournamentDetail:
            return true
        }
    }

    static func instance<T: UIViewController>(class type: T.Type) -> T {
        let classStr = String(describing: type)
        let abbreviation = String(classStr.prefix(classStr.count - "ViewController".count))
        let vcEnum = ViewController(rawValue: abbreviation)!
        if vcEnum.hasStoryboard {
            return UIStoryboard(name: vcEnum.rawValue, bundle: Bundle.main).instantiateInitialViewController() as! T
        } else {
            return T()
        }
    }

}

extension UIViewController {
    func withNavigation() -> UINavigationController {
        return withNavigation(class: UINavigationController.self)
    }

    func withNavigation<T: UINavigationController>(class type: T.Type) -> T {
        return T(rootViewController: self)
    }
}
