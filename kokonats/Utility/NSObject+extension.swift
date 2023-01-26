//
//  NSObject+extension.swift
//  kokonats
//
//  Created by iori on 2022/03/06.
//

import UIKit

typealias ActionHandler = () -> Void
typealias CompletionHandler = (Bool) -> Void
extension NSObject: ClassNameProtocol {}

protocol ClassNameProtocol {
    static var className: String { get }
    var className: String { get }
}

extension ClassNameProtocol {
    static var className: String {
        return String(describing: self)
    }
    
    var className: String {
        return type(of: self).className
    }
}
