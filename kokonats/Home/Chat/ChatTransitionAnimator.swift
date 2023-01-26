//
//  ChatTransitionAnimator.swift
//  kokonats
//  
//  Created by iori on 2022/03/13
//  


import UIKit

fileprivate struct Const {
    static let duration: Double = 0.5
}

protocol ChatTransitionAnimatable {
    var targetView: UIView { get }
}

class ChatTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    enum NavType {
        case push, pop, fade
    }
    
    private let navType: NavType
    private let targetOriginView: UIView
    private let targetDistView: UIView
    
    init(type: NavType, originView: UIView, distView: UIView) {
        self.navType = type
        self.targetOriginView = originView
        self.targetDistView = distView
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Const.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch navType {
        case .push: animationForPush(using: transitionContext)
        case .pop:  animationForPop(using: transitionContext)
        case .fade: animationForFade(using: transitionContext)
        }
    }
    
    // MARK: - push transition: shrink searchbar
    private func animationForPush(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else { return }
        
        transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
        let center = targetOriginView.center
        
        toView.alpha = 0
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       animations: {
            toView.alpha = 1
            fromView.alpha = 0
            self.targetOriginView.transform = CGAffineTransform(scaleX: 0.1, y: 1)
            self.targetOriginView.center = CGPoint(x: 35 + 20, y: 30)
        }) { didComplete in
            // reset all after animation
            toView.alpha = 1
            fromView.alpha = 1
            self.targetOriginView.transform = .identity
            self.targetOriginView.center = center
            transitionContext.completeTransition(didComplete)
        }
    }
    
    // MARK: - pop transition: back button expand
    private func animationForPop(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else { return }
        transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
        let center = CGPoint(x: toView.center.x, y: 30)
        let scaleX = (toView.frame.width - 35 * 2) / targetOriginView.frame.width
        self.targetDistView.alpha = 0
        self.targetDistView.transform = CGAffineTransform(scaleX: 1 / scaleX, y: 1)
        self.targetDistView.center = targetOriginView.center
        
        toView.alpha = 0
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            toView.alpha = 1
            fromView.alpha = 0
            self.targetDistView.transform = .identity
            self.targetDistView.center = center
            self.targetDistView.alpha = 1
        } completion: { didComplete in
            // reset all after animation
            toView.alpha = 1
            fromView.alpha = 1
            self.targetOriginView.transform = .identity
            self.targetDistView.transform = .identity
            self.targetDistView.center = center
            self.targetDistView.alpha = 1
            transitionContext.completeTransition(didComplete)
        }
    }
    
    // MARK: - fade transition
    private func animationForFade(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from),
              let toView = transitionContext.view(forKey: .to) else { return }
        transitionContext.containerView.insertSubview(toView, belowSubview: fromView)
        
        toView.alpha = 0
        UIView.animate(withDuration: transitionDuration(using: transitionContext)) {
            toView.alpha = 1
            fromView.alpha = 0
        } completion: { didComplete in
            // reset all after animation
            toView.alpha = 1
            fromView.alpha = 1
            transitionContext.completeTransition(didComplete)
        }
    }
}
