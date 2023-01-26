//
//  ChatNavigationController.swift
//  kokonats
//  
//  Created by iori on 2022/03/13
//  


import UIKit

class ChatNavigationController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
    }
    
    /** to prevent duplicate transitions */
    func pushMessageVC(vc: ChatMessageViewController, animated: Bool = true) {
        guard !self.viewControllers.isEmpty else {
            Logger.debug(#function + ": vcs is empty")
            return
        }
        if self.viewControllers.count == 1 {
            super.pushViewController(vc, animated: animated)
            return
        }
        let vcs = [self.viewControllers.first!, vc]
        self.setViewControllers(vcs, animated: animated)
    }
}

extension ChatNavigationController: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, animationControllerFor operation: UINavigationController.Operation, from fromVC: UIViewController, to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        guard let originView = (fromVC as? ChatTransitionAnimatable)?.targetView,
              let distView = (toVC as? ChatTransitionAnimatable)?.targetView else { return nil }
        if fromVC is ChatElementListViewController && toVC is ChatMessageViewController {
            return ChatTransitionAnimator(type: .push, originView: originView, distView: distView)
        }
        if fromVC is ChatMessageViewController && toVC is ChatElementListViewController {
            return ChatTransitionAnimator(type: .pop, originView: originView, distView: distView)
        }
        if fromVC is ChatMessageViewController && toVC is ChatMessageViewController {
            return ChatTransitionAnimator(type: .fade, originView: originView, distView: distView)
        }
        return nil
    }
}
