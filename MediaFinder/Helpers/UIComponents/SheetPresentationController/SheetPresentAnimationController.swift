import UIKit

final class SheetPresentAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Methods
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toView = transitionContext.view(forKey: .to),
            let toViewController = transitionContext.viewController(forKey: .to)
        else { return }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        toView.frame = finalFrame
        toView.frame.origin.y = containerView.bounds.height
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: .zero,
            options: .curveLinear,
            animations: { toView.frame = finalFrame },
            completion: { finished in transitionContext.completeTransition(finished) }
        )
    }
}
