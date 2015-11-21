//
//  ViewController.swift
//  SamplePresentation
//
//  Created by suwa.yuki on 2014/10/06.
//  Copyright (c) 2014年 underscore, Inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIViewControllerTransitioningDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func buttonDidTouch(sender: AnyObject) {
        
        let controller: UINavigationController! = self.storyboard?.instantiateViewControllerWithIdentifier("NavigationController") as? UINavigationController
        controller.modalPresentationStyle = .Custom
        controller.transitioningDelegate = self
        self.presentViewController(controller, animated: true, completion: {
        })
        
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController, sourceViewController source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAnimatedTransitioning(isPresent: true)
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAnimatedTransitioning(isPresent: false)
    }

}

class CustomPresentationController: UIPresentationController {
    
    var overlay: UIView!
    
    override func presentationTransitionWillBegin() {
        let containerView = self.containerView!
        
        self.overlay = UIView(frame: containerView.bounds)
        self.overlay.gestureRecognizers = [UITapGestureRecognizer(target: self, action: "overlayDidTouch:")]
        self.overlay.backgroundColor = UIColor.blackColor()
        self.overlay.alpha = 0.0
        containerView.insertSubview(self.overlay, atIndex: 0)
        
        presentedViewController.transitionCoordinator()?.animateAlongsideTransition({
            [unowned self] context in
            self.overlay.alpha = 0.5
        }, completion: nil)
    }
    
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator()?.animateAlongsideTransition({
            [unowned self] context in
            self.overlay.alpha = 0.0
        }, completion: nil)
    }
    
    override func dismissalTransitionDidEnd(completed: Bool) {
        if completed {
            self.overlay.removeFromSuperview()
        }
    }
    
    override func sizeForChildContentContainer(container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width / 2, height: parentSize.height)
    }
    
    override func frameOfPresentedViewInContainerView() -> CGRect {
        var presentedViewFrame = CGRectZero
        let containerBounds = containerView!.bounds
        presentedViewFrame.size = self.sizeForChildContentContainer(self.presentedViewController, withParentContainerSize: containerBounds.size)
        presentedViewFrame.origin.x = containerBounds.size.width - presentedViewFrame.size.width
        presentedViewFrame.origin.y = containerBounds.size.height - presentedViewFrame.size.height
        return presentedViewFrame
    }
    
    override func containerViewWillLayoutSubviews() {
        overlay.frame = containerView!.bounds
        self.presentedView()!.frame = self.frameOfPresentedViewInContainerView()
    }
    
    override func containerViewDidLayoutSubviews() {
    }
    
    func overlayDidTouch(sender: AnyObject) {
        self.presentedViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
}

class CustomAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    
    let isPresent: Bool
    
    init(isPresent: Bool) {
        self.isPresent = isPresent
    }
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.4
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if isPresent {
            animatePresentTransition(transitionContext)
        } else {
            animateDissmissalTransition(transitionContext)
        }
    }
    
    func animatePresentTransition(transitionContext: UIViewControllerContextTransitioning) {
        let presentingController: UIViewController! = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let presentedController: UIViewController! = transitionContext.viewControllerForKey(UITransitionContextToViewControllerKey)
        let containerView: UIView! = transitionContext.containerView()
        containerView.insertSubview(presentedController.view, belowSubview: presentingController.view)
        //適当にアニメーション
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            presentedController.view.frame.origin.x -= containerView.bounds.size.width
            }, completion: {
                finished in
                transitionContext.completeTransition(true)
        })
    }
    
    func animateDissmissalTransition(transitionContext: UIViewControllerContextTransitioning) {
        let presentedController: UIViewController! = transitionContext.viewControllerForKey(UITransitionContextFromViewControllerKey)
        let containerView: UIView! = transitionContext.containerView()
        //適当にアニメーション
        UIView.animateWithDuration(self.transitionDuration(transitionContext), animations: {
            presentedController.view.frame.origin.x = containerView.bounds.size.width
            }, completion: {
                finished in
                transitionContext.completeTransition(true)
        })
    }
    
}
