//
//  UITableView+extension.swift
//  kokonats
//
//  Created by iori on 2022/03/06.
//

import UIKit

extension UITableView {
    
    func register(_ cellClass: UITableViewCell.Type) {
        self.register(cellClass, forCellReuseIdentifier: cellClass.className)
    }
    
    func register(_ cellClasses: [UITableViewCell.Type]) {
        cellClasses.forEach { self.register($0) }
    }
    
    // ref: https://stackoverflow.com/questions/33705371/how-to-scroll-to-the-exact-end-of-the-uitableview
    func scrollToBottom(animated: Bool = true){
        DispatchQueue.main.async {
            let indexPath = IndexPath(
                row: self.numberOfRows(inSection:  self.numberOfSections-1) - 1,
                section: self.numberOfSections - 1)
            if indexPath.row >= 0 && indexPath.section >= 0 && self.hasRowAtIndexPath(indexPath: indexPath) {
                self.scrollToRow(at: indexPath, at: .bottom, animated: animated)
            }
        }
    }
    
    func hasRowAtIndexPath(indexPath: IndexPath) -> Bool {
        return indexPath.section < self.numberOfSections && indexPath.row < self.numberOfRows(inSection: indexPath.section)
    }
}
