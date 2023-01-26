////  UIComponents+extension.swift
//  kokonats
//
//  Created by sean on 2021/12/11.
//  
//

import Foundation
import UIKit

extension UIColor {
    private static func kokoColor(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) -> UIColor {
        return UIColor(red: CGFloat(red)/255, green: CGFloat(green)/255, blue: CGFloat(blue)/255, alpha: alpha)
    }
    
    static var kokoBgColor: UIColor {
        return kokoColor(red: 25, green: 26, blue: 50)
    }

    //background: rgba(33, 40, 63, 1);
    static var lightBgColor: UIColor {
        return kokoColor(red: 33, green: 40, blue: 63)
    }
    
    static var kokoBgGray: UIColor {
        return kokoColor(red: 118, green: 118, blue: 118)
    }
    
    static var kokoBgGray2: UIColor {
        return kokoColor(red: 196, green: 196, blue: 196)
    }
    
    static var textBgColor: UIColor {
        return kokoColor(red: 50, green: 55, blue: 85)
    }

    static var selectedColor: UIColor {
        return kokoColor(red: 72, green: 112, blue: 255)
    }

    static var kokoYellow: UIColor {
        return kokoColor(red: 255, green: 203, blue: 0)
    }

    static var kokoLightYellow: UIColor {
        return kokoColor(red: 255, green: 203, blue: 0, alpha: 0.1)
    }
    
    static var kokoOrange: UIColor {
        return kokoColor(red: 255, green: 153, blue: 0)
    }

    static var kokoGreen: UIColor {
        return kokoColor(red: 0, green: 203, blue: 117)
    }

    static var kokoRed: UIColor {
        return kokoColor(red: 220, green: 83, blue: 40)
    }
    
    static var kokoGreenStamp: UIColor {
        return kokoColor(red: 79, green: 198, blue: 185)
    }

    static var dollarYellow: UIColor {
        return kokoColor(red: 255, green: 190, blue: 44)
    }

    static var rankingLightWhite: UIColor {
        return kokoColor(red: 38, green: 47, blue: 82)
    }

    static var bannerBlue: UIColor {
        return kokoColor(red: 0, green: 56, blue: 245)
    }

    static var bannerPurple: UIColor {
        return kokoColor(red: 159, green: 3, blue: 255)
    }

    static var keywordBlackBg: UIColor {
        return kokoColor(red: 38, green: 36, blue: 38)
    }

    static var firstScoreBg: UIColor {
        return kokoColor(red: 239, green: 93, blue: 168)
    }

    static var secondScoreBg: UIColor {
        return kokoColor(red: 241, green: 120, blue: 182)
    }

    static var thirdScoreBg: UIColor {
        return kokoColor(red: 252, green: 221, blue: 236)
    }

    static var ticketContainerBg: UIColor {
        return kokoColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }

    static var lightWhiteFontColor: UIColor {
        return kokoColor(red: 216, green: 216, blue: 216)
    }

    static var purchasedLabelColor: UIColor {
        return kokoColor(red: 66, green: 79, blue: 122)
    }
    
    static var recommendedEnergyColor: UIColor {
        return kokoColor(red: 235, green: 87, blue: 87)
    }
    
    static var profilePhotoBgs: [UIColor] {
        return [
            UIColor.clear,
            kokoColor(red: 200, green: 244, blue: 207),
            kokoColor(red: 223, green: 214, blue: 253),
            kokoColor(red: 255, green: 197, blue: 200),
            kokoColor(red: 221, green: 221, blue: 222),
            kokoColor(red: 221, green: 206, blue: 200)        
        ]
    }
    
    static var itemListBg: UIColor {
        return kokoColor(red: 191, green: 198, blue: 221)
    }

}

// Initializer
extension Date {
    init(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) {
        self.init(
            timeIntervalSince1970: Date().fixed(
                year:   year,
                month:  month,
                day:    day,
                hour:   hour,
                minute: minute,
                second: second
            ).timeIntervalSince1970
        )
    }
}

extension Date {
    func kokoFormated() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY/MM/dd HH:mm:ss"
        return formatter.string(from: self)
    }
    
    func kokoChatFormated() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: self)
    }
    
    var zeroclock: Date {
        return fixed(hour: 0, minute: 0, second: 0)
    }
    
    var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        calendar.locale   = .current
        return calendar
    }
    
    func fixed(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        let calendar = self.calendar
        
        var comp = DateComponents()
        comp.year   = year   ?? calendar.component(.year,   from: self)
        comp.month  = month  ?? calendar.component(.month,  from: self)
        comp.day    = day    ?? calendar.component(.day,    from: self)
        comp.hour   = hour   ?? calendar.component(.hour,   from: self)
        comp.minute = minute ?? calendar.component(.minute, from: self)
        comp.second = second ?? calendar.component(.second, from: self)
        
        return calendar.date(from: comp)!
    }
    
    func added(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        let calendar = self.calendar
        
        var comp = DateComponents()
        comp.year   = (year   ?? 0) + calendar.component(.year,   from: self)
        comp.month  = (month  ?? 0) + calendar.component(.month,  from: self)
        comp.day    = (day    ?? 0) + calendar.component(.day,    from: self)
        comp.hour   = (hour   ?? 0) + calendar.component(.hour,   from: self)
        comp.minute = (minute ?? 0) + calendar.component(.minute, from: self)
        comp.second = (second ?? 0) + calendar.component(.second, from: self)
        
        return calendar.date(from: comp)!
    }
}

extension UIViewController {
    func showErrorMessage(title: String, reason: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: reason , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Default action"), style: .default, handler: { _ in
            completion?()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showConfirmDialog(type: ConfirmDialogType = .question, title: String, message: String, textOk: String, textCancel: String, onOk: (() -> Void)? = nil, onCancel: (() -> Void)? = nil) {
        let dialog = ConfirmDialogViewController(type, title: title, message: message, textOk: textOk, textCancel: textCancel, onOk: onOk, onCancel: onCancel)
        dialog.modalPresentationStyle = .custom
        dialog.modalTransitionStyle = .crossDissolve
        self.present(dialog, animated: false, completion: nil)
    }
    
    func showAlertDialog(type: ConfirmDialogType = .info, title: String, message: String, textOk: String, onOk: (() -> Void)? = nil) {
        let dialog = AlertDialogViewController(type, title: title, message: message, textOk: textOk, onOk: onOk)
        dialog.modalPresentationStyle = .custom
        dialog.modalTransitionStyle = .crossDissolve
        self.present(dialog, animated: false, completion: nil)
    }
}

extension Int {
    func formatedString() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 0

        return formatter.string(from: NSNumber(value: self)) ?? ""
    }
}

extension String {
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
    
    /// format "HH:mm:ss"  return today's date time
    func kokoTimeStrToDate() -> Date? {
        let today = Date().zeroclock // YYYY/MM/dd 00:00:00
        let f1 = DateFormatter()
        f1.dateFormat = "YYYY/MM/dd"
        let todayStr = f1.string(from: today)
        let targetDateStr = "\(todayStr) \(self)"
        let f2 = DateFormatter()
        f2.timeZone = .current
        f2.locale = .current
        f2.dateFormat = "YYYY/MM/dd HH:mm:ss"
        return f2.date(from: targetDateStr)
    }
    
    func convertPngBase64ToData() -> Data? {
        let base64String = self.replacingOccurrences(of: "data:image/png+xml;base64,", with: "")
        if let data = Data(base64Encoded: base64String) {
            return data
        }
        return nil
    }
}

extension Array {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
