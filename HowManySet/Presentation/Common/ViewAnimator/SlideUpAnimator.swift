//
//  SlideUpAnimator.swift
//  HowManySet
//
//  Created by 정근호 on 6/18/25.
//

import UIKit

final class SlideUpAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toView = transitionContext.view(forKey: .to) else { return }
        let container = transitionContext.containerView
        toView.transform = CGAffineTransform(translationX: 0, y: container.bounds.height)
        container.addSubview(toView)

        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toView.transform = .identity
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}
