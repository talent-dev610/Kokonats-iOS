//
//  TutorialPagerController.swift
//  kokonats
//
//  Created by George on 2022-05-03.
//

import Foundation
import UIKit

@objc public protocol TutorialPageControllerDataSource {
    func tutorialPageViewController(_ pageViewController: TutorialPageController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController?
    
    func tutorialPageViewController(_ pageViewController: TutorialPageController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController?
}

@objc public protocol TutorialPageControllerDelegate {
    @objc optional func tutorialPageController(_ pageViewController: TutorialPageController, willStartScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController)
    
    @objc optional func tutorialPageController(_ pageViewController: TutorialPageController, isScrollingFrom startingViewController: UIViewController, destinationViewController: UIViewController, progress: CGFloat)
    
    @objc optional func tutorialPageController(_ pageViewController: TutorialPageController, didFinishScrollingFrom startingViewController: UIViewController?, destinationViewController: UIViewController, transitionSuccessful: Bool)
}

@objc public enum TutorialPageControllerNavigationDirection : Int {
    case forward
    case reverse
}

@objc public enum TutorialPageControllerNavigationOrientation: Int {
    case horizontal
    case vertical
}

open class TutorialPageController: UIViewController, UIScrollViewDelegate {
    @objc open weak var dataSource: TutorialPageControllerDataSource?
    @objc open weak var delegate: TutorialPageControllerDelegate?
    open private(set) var navigationOrientation: TutorialPageControllerNavigationOrientation = .horizontal
    
    private var isOrientationHorizontal: Bool {
        return self.navigationOrientation == .horizontal
    }
    
    open private(set) lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = false
        scrollView.scrollsToTop = false
        scrollView.autoresizingMask = [.flexibleTopMargin, .flexibleRightMargin, .flexibleBottomMargin, .flexibleLeftMargin]
        scrollView.bounces = true
        scrollView.alwaysBounceHorizontal = self.isOrientationHorizontal
        scrollView.alwaysBounceVertical = !self.isOrientationHorizontal
        scrollView.translatesAutoresizingMaskIntoConstraints = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.layer.cornerRadius = 20
        scrollView.backgroundColor = .white
        return scrollView
    }()
    
    private var beforeViewController: UIViewController?
    @objc open private(set) var selectedViewController: UIViewController?
    private var afterViewController: UIViewController?
    @objc open private(set) var scrolling = false
    open private(set) var navigationDirection: TutorialPageControllerNavigationDirection?
    private var adjustingContentOffset = false
    private var loadNewAdjoiningViewControllersOnFinish = false
    private var didFinishScrollingCompletionHandler: ((_ transitionSuccessful: Bool) -> Void)?
    private var transitionAnimated = false
    
    public convenience init(navigationOrientation: TutorialPageControllerNavigationOrientation) {
           self.init()
           self.navigationOrientation = navigationOrientation
       }
    
    @objc open func selectViewController(_ viewController: UIViewController, direction: TutorialPageControllerNavigationDirection, animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
            
            if (direction == .forward) {
                self.afterViewController = viewController
                self.layoutViews()
                self.loadNewAdjoiningViewControllersOnFinish = true
                self.scrollForward(animated: animated, completion: completion)
            } else if (direction == .reverse) {
                self.beforeViewController = viewController
                self.layoutViews()
                self.loadNewAdjoiningViewControllersOnFinish = true
                self.scrollReverse(animated: animated, completion: completion)
            }
        }
    
    @objc(scrollForwardAnimated:completion:)
        open func scrollForward(animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
            if (self.afterViewController != nil) {
                // Cancel current animation and move
                if self.scrolling {
                    if self.isOrientationHorizontal {
                        self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width * 2, y: 0), animated: false)
                    } else {
                        self.scrollView.setContentOffset(CGPoint(x: 0, y: self.view.bounds.height * 2), animated: false)
                    }
                    
                }
                
                self.didFinishScrollingCompletionHandler = completion
                self.transitionAnimated = animated
                if self.isOrientationHorizontal {
                    self.scrollView.setContentOffset(CGPoint(x: self.view.bounds.width * 2, y: 0), animated: animated)
                } else {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: self.view.bounds.height * 2), animated: animated)
                }
                
            }
        }
    
    @objc(scrollReverseAnimated:completion:)
        open func scrollReverse(animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
            if (self.beforeViewController != nil) {
                
                // Cancel current animation and move
                if self.scrolling {
                    self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                }
                
                self.didFinishScrollingCompletionHandler = completion
                self.transitionAnimated = animated
                self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: animated)
            }
        }
    
    @nonobjc @available(*, unavailable, renamed: "scrollForward(animated:completion:)")
        open func scrollForwardAnimated(_ animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
            self.scrollForward(animated: animated, completion: completion)
        }

        @nonobjc @available(*, unavailable, renamed: "scrollReverse(animated:completion:)")
        open func scrollReverseAnimated(_ animated: Bool, completion: ((_ transitionSuccessful: Bool) -> Void)?) {
            self.scrollReverse(animated: animated, completion: completion)
        }
    
    open override var shouldAutomaticallyForwardAppearanceMethods : Bool {
            return false
        }
        
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .clear
        self.view.frame = CGRect(x: 0 , y: 0, width: self.view.frame.width * 0.8, height: self.view.frame.height * 0.7)
        self.view.layer.cornerRadius = 20
        self.scrollView.delegate = self
        self.view.addSubview(self.scrollView)
    }
        
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard !scrolling else {
            return
        }
        
        self.scrollView.frame = self.view.bounds
        if self.isOrientationHorizontal {
            self.scrollView.contentSize = CGSize(width: self.view.bounds.width * 3, height: self.view.bounds.height)
        } else {
            self.scrollView.contentSize = CGSize(width: self.view.bounds.width, height: self.view.bounds.height * 3)
        }

        self.layoutViews()
    }
        
        
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let selectedViewController = self.selectedViewController {
            selectedViewController.beginAppearanceTransition(true, animated: animated)
        }
    }

     open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let selectedViewController = self.selectedViewController {
            selectedViewController.endAppearanceTransition()
        }
    }

     open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let selectedViewController = self.selectedViewController {
            selectedViewController.beginAppearanceTransition(false, animated: animated)
        }
    }

     open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if let selectedViewController = self.selectedViewController {
            selectedViewController.endAppearanceTransition()
        }
    }
        
        
        // MARK: - View Controller Management
        
        private func loadViewControllers(_ selectedViewController: UIViewController) {
            
            // Scrolled forward
            if (selectedViewController == self.afterViewController) {
                
                // Shift view controllers forward
                self.beforeViewController = self.selectedViewController
                self.selectedViewController = self.afterViewController
                
                self.selectedViewController!.endAppearanceTransition()
                
                self.removeChildIfNeeded(self.beforeViewController)
                self.beforeViewController?.endAppearanceTransition()
                
                self.delegate?.tutorialPageController?(self, didFinishScrollingFrom: self.beforeViewController, destinationViewController: self.selectedViewController!, transitionSuccessful: true)
                
                self.didFinishScrollingCompletionHandler?(true)
                self.didFinishScrollingCompletionHandler = nil
                
                // Load new before view controller if required
                if self.loadNewAdjoiningViewControllersOnFinish {
                    self.loadBeforeViewController(for: selectedViewController)
                    self.loadNewAdjoiningViewControllersOnFinish = false
                }
                
                // Load new after view controller
                self.loadAfterViewController(for: selectedViewController)
                
                
            // Scrolled reverse
            } else if (selectedViewController == self.beforeViewController) {
                
                // Shift view controllers reverse
                self.afterViewController = self.selectedViewController
                self.selectedViewController = self.beforeViewController
                
                self.selectedViewController!.endAppearanceTransition()
                
                self.removeChildIfNeeded(self.afterViewController)
                self.afterViewController?.endAppearanceTransition()
                
                self.delegate?.tutorialPageController?(self, didFinishScrollingFrom: self.afterViewController!, destinationViewController: self.selectedViewController!, transitionSuccessful: true)
                
                self.didFinishScrollingCompletionHandler?(true)
                self.didFinishScrollingCompletionHandler = nil
                
                // Load new after view controller if required
                if self.loadNewAdjoiningViewControllersOnFinish {
                    self.loadAfterViewController(for: selectedViewController)
                    self.loadNewAdjoiningViewControllersOnFinish = false
                }
                
                // Load new before view controller
                self.loadBeforeViewController(for: selectedViewController)
            
            // Scrolled but ended up where started
            } else if (selectedViewController == self.selectedViewController) {
                
                self.selectedViewController!.beginAppearanceTransition(true, animated: self.transitionAnimated)
                
                if (self.navigationDirection == .forward) {
                    self.afterViewController!.beginAppearanceTransition(false, animated: self.transitionAnimated)
                } else if (self.navigationDirection == .reverse) {
                    self.beforeViewController!.beginAppearanceTransition(false, animated: self.transitionAnimated)
                }
                
                self.selectedViewController!.endAppearanceTransition()
                
                // Remove hidden view controllers
                self.removeChildIfNeeded(self.beforeViewController)
                self.removeChildIfNeeded(self.afterViewController)
                
                if (self.navigationDirection == .forward) {
                    self.afterViewController!.endAppearanceTransition()
                    self.delegate?.tutorialPageController?(self, didFinishScrollingFrom: self.selectedViewController!, destinationViewController: self.afterViewController!, transitionSuccessful: false)
                } else if (self.navigationDirection == .reverse) {
                    self.beforeViewController!.endAppearanceTransition()
                    self.delegate?.tutorialPageController?(self, didFinishScrollingFrom: self.selectedViewController!, destinationViewController: self.beforeViewController!, transitionSuccessful: false)
                }
                
                self.didFinishScrollingCompletionHandler?(false)
                self.didFinishScrollingCompletionHandler = nil
                
                if self.loadNewAdjoiningViewControllersOnFinish {
                    if (self.navigationDirection == .forward) {
                        self.loadAfterViewController(for: selectedViewController)
                    } else if (self.navigationDirection == .reverse) {
                        self.loadBeforeViewController(for: selectedViewController)
                    }
                }
                
            }
            
            self.navigationDirection = nil
            self.scrolling = false
            
        }
        
        private func loadBeforeViewController(for selectedViewController:UIViewController) {
            // Retreive the new before controller from the data source if available, otherwise set as nil
            self.beforeViewController = self.dataSource?.tutorialPageViewController(self, viewControllerBeforeViewController: selectedViewController)
        }
        
        private func loadAfterViewController(for selectedViewController:UIViewController) {
            // Retreive the new after controller from the data source if available, otherwise set as nil
            self.afterViewController = self.dataSource?.tutorialPageViewController(self, viewControllerAfterViewController: selectedViewController)
        }
        
        
        // MARK: - View Management
        
        private func addChildIfNeeded(_ viewController: UIViewController) {
            self.scrollView.addSubview(viewController.view)
            self.addChild(viewController)
            viewController.didMove(toParent: self)
        }
        
        private func removeChildIfNeeded(_ viewController: UIViewController?) {
            viewController?.view.removeFromSuperview()
            viewController?.didMove(toParent: nil)
            viewController?.removeFromParent()
        }
        
        private func layoutViews() {
            
            let viewWidth = self.view.bounds.width
            let viewHeight = self.view.bounds.height
            
            var beforeInset:CGFloat = 0
            var afterInset:CGFloat = 0
            
            if (self.beforeViewController == nil) {
                beforeInset = self.isOrientationHorizontal ? -viewWidth : -viewHeight
            }
            
            if (self.afterViewController == nil) {
                afterInset = self.isOrientationHorizontal ? -viewWidth : -viewHeight
            }
            
            self.adjustingContentOffset = true
            self.scrollView.contentOffset = CGPoint(x: self.isOrientationHorizontal ? viewWidth : 0, y: self.isOrientationHorizontal ? 0 : viewHeight)
            if self.isOrientationHorizontal {
                self.scrollView.contentInset = UIEdgeInsets.init(top: 0, left: beforeInset, bottom: 0, right: afterInset)
            } else {
                self.scrollView.contentInset = UIEdgeInsets.init(top: beforeInset, left: 0, bottom: afterInset, right: 0)
            }
            self.adjustingContentOffset = false
            
            if self.isOrientationHorizontal {
                self.beforeViewController?.view.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
                self.selectedViewController?.view.frame = CGRect(x: viewWidth, y: 0, width: viewWidth, height: viewHeight)
                self.afterViewController?.view.frame = CGRect(x: viewWidth * 2, y: 0, width: viewWidth, height: viewHeight)
            } else {
                self.beforeViewController?.view.frame = CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight)
                self.selectedViewController?.view.frame = CGRect(x: 0, y: viewHeight, width: viewWidth, height: viewHeight)
                self.afterViewController?.view.frame = CGRect(x: 0, y: viewHeight * 2, width: viewWidth, height: viewHeight)
            }
            
        }
        
        
        // MARK: - Internal Callbacks
        
        private func willScroll(from startingViewController: UIViewController?, to destinationViewController: UIViewController) {
            if (startingViewController != nil) {
                self.delegate?.tutorialPageController?(self, willStartScrollingFrom: startingViewController!, destinationViewController: destinationViewController)
            }
            
            destinationViewController.beginAppearanceTransition(true, animated: self.transitionAnimated)
            startingViewController?.beginAppearanceTransition(false, animated: self.transitionAnimated)
            self.addChildIfNeeded(destinationViewController)
        }
        
        private func didFinishScrolling(to viewController: UIViewController) {
            self.loadViewControllers(viewController)
            self.layoutViews()
        }
        
        
        // MARK: - UIScrollView Delegate
        
        open func scrollViewDidScroll(_ scrollView: UIScrollView) {
            if !adjustingContentOffset {
            
                let distance = self.isOrientationHorizontal ? self.view.bounds.width : self.view.bounds.height
                let progress = ((self.isOrientationHorizontal ? scrollView.contentOffset.x : scrollView.contentOffset.y) - distance) / distance
                
                // Scrolling forward / after
                if (progress > 0) {
                    if (self.afterViewController != nil) {
                        if !scrolling { // call willScroll once
                            self.willScroll(from: self.selectedViewController, to: self.afterViewController!)
                            self.scrolling = true
                        }
                        
                        if self.navigationDirection == .reverse { // check if direction changed
                            self.didFinishScrolling(to: self.selectedViewController!)
                            self.willScroll(from: self.selectedViewController, to: self.afterViewController!)
                        }
                        
                        self.navigationDirection = .forward
                        
                        if (self.selectedViewController != nil) {
                            self.delegate?.tutorialPageController?(self, isScrollingFrom: self.selectedViewController!, destinationViewController: self.afterViewController!, progress: progress)
                        }
                    }
                    
                // Scrolling reverse / before
                } else if (progress < 0) {
                    if (self.beforeViewController != nil) {
                        if !scrolling { // call willScroll once
                            self.willScroll(from: self.selectedViewController, to: self.beforeViewController!)
                            self.scrolling = true
                        }
                        
                        if self.navigationDirection == .forward { // check if direction changed
                            self.didFinishScrolling(to: self.selectedViewController!)
                            self.willScroll(from: self.selectedViewController, to: self.beforeViewController!)
                        }
                        
                        self.navigationDirection = .reverse
                        
                        if (self.selectedViewController != nil) {
                            self.delegate?.tutorialPageController?(self, isScrollingFrom: self.selectedViewController!, destinationViewController: self.beforeViewController!, progress: progress)
                        }
                    }
                    
                // At zero
                } else {
                    if (self.navigationDirection == .forward) {
                        self.delegate?.tutorialPageController?(self, isScrollingFrom: self.selectedViewController!, destinationViewController: self.afterViewController!, progress: progress)
                    } else if (self.navigationDirection == .reverse) {
                        self.delegate?.tutorialPageController?(self, isScrollingFrom: self.selectedViewController!, destinationViewController: self.beforeViewController!, progress: progress)
                    }
                }
                
                // Thresholds to update view layouts call delegates
                if (progress >= 1 && self.afterViewController != nil) {
                    self.didFinishScrolling(to: self.afterViewController!)
                } else if (progress <= -1  && self.beforeViewController != nil) {
                    self.didFinishScrolling(to: self.beforeViewController!)
                } else if (progress == 0  && self.selectedViewController != nil) {
                    self.didFinishScrolling(to: self.selectedViewController!)
                }
                
            }
            
        }
        
        open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            self.transitionAnimated = true
        }
        
        open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
            // setContentOffset is called to center the selected view after bounces
            // This prevents yucky behavior at the beginning and end of the page collection by making sure setContentOffset is called only if...
            
            if self.isOrientationHorizontal {
                if  (self.beforeViewController != nil && self.afterViewController != nil) || // It isn't at the beginning or end of the page collection
                    (self.afterViewController != nil && self.beforeViewController == nil && scrollView.contentOffset.x > abs(scrollView.contentInset.left)) || // If it's at the beginning of the collection, the decelleration can't be triggered by scrolling away from, than torwards the inset
                    (self.beforeViewController != nil && self.afterViewController == nil && scrollView.contentOffset.x < abs(scrollView.contentInset.right)) { // Same as the last condition, but at the end of the collection
                        scrollView.setContentOffset(CGPoint(x: self.view.bounds.width, y: 0), animated: true)
                }
            } else {
                if  (self.beforeViewController != nil && self.afterViewController != nil) || // It isn't at the beginning or end of the page collection
                    (self.afterViewController != nil && self.beforeViewController == nil && scrollView.contentOffset.y > abs(scrollView.contentInset.top)) || // If it's at the beginning of the collection, the decelleration can't be triggered by scrolling away from, than torwards the inset
                    (self.beforeViewController != nil && self.afterViewController == nil && scrollView.contentOffset.y < abs(scrollView.contentInset.bottom)) { // Same as the last condition, but at the end of the collection
                        scrollView.setContentOffset(CGPoint(x: 0, y: self.view.bounds.height), animated: true)
                }
            }
            
        }
}
