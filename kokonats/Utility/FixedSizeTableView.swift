//
//  FixedSizeTableView.swift
//  kokonats
//
//  Created by yifei.zhou on 2021/09/29.
//

import UIKit

class FixedSizeTableView: UITableView {
    override var intrinsicContentSize: CGSize {
           self.layoutIfNeeded()
           return self.contentSize
       }

       override var contentSize: CGSize {
           didSet{
               self.invalidateIntrinsicContentSize()
           }
       }

       override func reloadData() {
           super.reloadData()
           self.invalidateIntrinsicContentSize()
       }
}
