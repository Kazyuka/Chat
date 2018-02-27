//
//  PresentAnimation.swift
//  TestChat
//
//  Created by Руслан Казюка on 27.02.2018.
//  Copyright © 2018 Руслан Казюка. All rights reserved.
//
import UIKit

class PresentAnimation: NSObject {

    enum transitionMode {
        case presentation
        case dissmiss
    }
    public var presentDefault = transitionMode.presentation
    public var duraction = 2.0
}
extension PresentAnimation: UIViewControllerAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duraction
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to),
            let snapshot = toVC.view.snapshotView(afterScreenUpdates: true)
            else {
                return
        }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        snapshot.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        snapshot.layer.cornerRadius = 20
        snapshot.layer.masksToBounds = true
        
        
        containerView.addSubview(toVC.view)
        containerView.backgroundColor = UIColor.white
        containerView.addSubview(snapshot)
        toVC.view.isHidden = true
        
        AnimationHelper.perspectiveTransform(for: containerView)
        snapshot.layer.transform = AnimationHelper.yRotation(.pi / 2)
        let duration = transitionDuration(using: transitionContext)
        
        switch presentDefault {
        case .dissmiss:
            print("dissmis");
            
        case .presentation:
            UIView.animateKeyframes(
                withDuration: 0.5,
                delay: 0,
                options: .calculationModeCubicPaced,
                animations: {
                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 1/3) {
                        fromVC.view.layer.transform = AnimationHelper.yRotation(-.pi / 2)
                    }
                    
                    UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3) {
                        snapshot.layer.transform = AnimationHelper.yRotation(0.0)
                    }
                    
                    UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3) {
                        snapshot.frame = finalFrame
                        snapshot.layer.cornerRadius = 0
                    }
            },
                completion: { _ in
                    toVC.view.isHidden = false
                    snapshot.removeFromSuperview()
                    fromVC.view.layer.transform = CATransform3DIdentity
                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            })
            
        default:
            break
        }
    }
    
}
