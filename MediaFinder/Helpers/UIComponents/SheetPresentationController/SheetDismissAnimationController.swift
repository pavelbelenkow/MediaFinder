import UIKit

final class SheetDismissAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    // MARK: - Methods
    
    func transitionDuration(
        using transitionContext: UIViewControllerContextTransitioning?
    ) -> TimeInterval {
        0.25
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromView = transitionContext.view(forKey: .from) else { return }
        let containerView = transitionContext.containerView
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: .zero,
            options: .curveEaseOut,
            animations: { fromView.frame = containerView.frame },
            completion: { finished in transitionContext.completeTransition(finished) }
        )
    }
}
