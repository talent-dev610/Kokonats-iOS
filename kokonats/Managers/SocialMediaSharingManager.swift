//
//  SocialManager.swift
//  kokonats
//
//  Created by George on 5/21/22.
//

import Foundation
import Social

public protocol SocialMediaSharable {
    func url() -> String
    func text() -> String
}

struct SharablePost: SocialMediaSharable {
    private let urlObj: String
    private let textObj: String
    
    init(url: String, text: String) {
    self.urlObj = url
    self.textObj = text
    }

    func url() -> String {
        return self.urlObj
    }

    func text() -> String {
        return self.textObj
    }
}

public class SocialMediaSharingManager {
    
    public  static func share(object: SocialMediaSharable) {
        let shareString = "https://twitter.com/intent/tweet?text=\(object.text())&url=\(object.url())"
        let escapedShareString = shareString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let url = URL(string: escapedShareString)
        UIApplication.shared.openURL(url!)
    }
}
