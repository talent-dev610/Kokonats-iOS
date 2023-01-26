////  PurchaseEnergyMarkView.swift
//  kokonats
//
//  Created by sean on 2021/11/27.
//  
//

import Foundation
import UIKit

class PurchaseEnergyMarkView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)

    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension UIImageView {
    func getAddingEnergyView() -> UIImageView {
        let imageView = UIImageView(image: UIImage(named: "add_energy_200"))
        imageView.activeSelfConstrains([.height(30), .width(90)])
        return imageView
    }
}
