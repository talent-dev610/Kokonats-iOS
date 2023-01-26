////  UIView+extension.swift
//  kokonats
//
//  Created by sean on 2021/10/04.
//  
//

import UIKit

protocol AnchorsProvider {
    var leadingAnchor: NSLayoutXAxisAnchor { get }
    var trailingAnchor: NSLayoutXAxisAnchor { get }
    var topAnchor: NSLayoutYAxisAnchor{ get }
    var bottomAnchor: NSLayoutYAxisAnchor { get }
}

extension UIView: AnchorsProvider { }
extension UILayoutGuide: AnchorsProvider {}

extension UIView {
    static func loadNib(from nibName: String) -> UIView? {
        let nib = UINib(nibName: nibName, bundle: nil)
        let components = nib.instantiate(withOwner: self, options: nil)
        return components.first as? UIView
    }

    var leading: NSLayoutXAxisAnchor { return leadingAnchor }
    var trailing: NSLayoutXAxisAnchor { return trailingAnchor }
    var top: NSLayoutYAxisAnchor { return topAnchor }
    var bottom: NSLayoutYAxisAnchor { return bottomAnchor }

    enum XAxisAnchor {
        case leading
        case trailing

        func anchor(of anchors: AnchorsProvider) -> NSLayoutXAxisAnchor {
            switch self {
            case .leading:
                return anchors.leadingAnchor
            case .trailing:
                return anchors.trailingAnchor
            }
        }
    }

    enum YAxisAnchor {
        case top
        case bottom

        func anchor(of anchors: AnchorsProvider) -> NSLayoutYAxisAnchor {
            switch self {
            case .top:
                return anchors.topAnchor
            case .bottom:
                return anchors.bottomAnchor
            }
        }
    }

    enum ViewSide {
        case top(YAxisAnchor = .top, CGFloat = 0)
        case trailing(XAxisAnchor = .trailing, CGFloat = 0)
        case bottom(YAxisAnchor = .bottom, CGFloat = 0)
        case leading(XAxisAnchor = .leading, CGFloat = 0)
        case centerX
        case centerY
    }

    enum SelfAnchor {
        case width(CGFloat)
        case height(CGFloat)
    }

    func activeSelfConstrains(_ anchors: [SelfAnchor]) {
        self.translatesAutoresizingMaskIntoConstraints = false
        anchors.forEach {
            switch $0 {
            case .height(let constant):
                heightAnchor.constraint(equalToConstant: constant).isActive = true
            case .width(let constant):
                widthAnchor.constraint(equalToConstant: constant).isActive = true
            }
        }
    }
    func activeConstraints(to layout: UILayoutGuide, anchorDirections: [ViewSide]) {
        self.translatesAutoresizingMaskIntoConstraints = false
        anchorDirections.forEach {
            switch $0 {
            case .top(let yAnchor, let constant):
                topAnchor.constraint(equalTo: yAnchor.anchor(of: layout), constant: constant).isActive = true
            case .bottom(let yAnchor, let constant):
                bottomAnchor.constraint(equalTo: yAnchor.anchor(of: layout), constant: constant).isActive = true
            case .trailing(let xAnchor, let constant):
                trailingAnchor.constraint(equalTo: xAnchor.anchor(of: layout), constant: constant).isActive = true
            case .leading(let xAnchor, let constant):
                leadingAnchor.constraint(equalTo: xAnchor.anchor(of: layout), constant: constant).isActive = true
            default:
                break
            }
        }
    }

    func activeConstraints(to view: UIView? = nil, directions: [ViewSide]? = nil) {
        self.translatesAutoresizingMaskIntoConstraints = false
        let targetView: UIView
        if let view = view {
            targetView = view
        } else if let superview = self.superview {
            targetView = superview
        } else {
            return
        }

        let anchorDirections: [ViewSide] = {
            if let directions = directions {
                return directions
            } else {
                return [.top(), .bottom(), .leading(), .trailing()]
            }
        }()

        anchorDirections.forEach {
            switch $0 {
            case .top(let yAnchor, let constant):
                topAnchor.constraint(equalTo: yAnchor.anchor(of: targetView), constant: constant).isActive = true
            case .bottom(let yAnchor, let constant):
                bottomAnchor.constraint(equalTo: yAnchor.anchor(of: targetView), constant: constant).isActive = true
            case .trailing(let xAnchor, let constant):
                trailingAnchor.constraint(equalTo: xAnchor.anchor(of: targetView), constant: constant).isActive = true
            case .leading(let xAnchor, let constant):
                leadingAnchor.constraint(equalTo: xAnchor.anchor(of: targetView), constant: constant).isActive = true
            case .centerX:
                centerXAnchor.constraint(equalTo: targetView.centerXAnchor).isActive = true
            case .centerY:
                centerYAnchor.constraint(equalTo: targetView.centerYAnchor).isActive = true
            default:
                break
            }
        }
    }
    
    func clickEffect() {
        alpha = 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.alpha = 1.0
        }
    }
}
