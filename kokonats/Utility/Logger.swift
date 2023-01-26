////  Logger.swift
//  kokonats
//
//  Created by sean on 2021/11/01.
//  
//

import Foundation

class Logger {
    static func debug(_ message: String) {
        #if DEBUG
            print("kokodebug " + message)
        #endif
    }
}
