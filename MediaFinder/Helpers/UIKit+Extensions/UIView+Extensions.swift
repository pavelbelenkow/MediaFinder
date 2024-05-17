import UIKit

// MARK: - Private Methods

private extension UIView {
    
    func animateScale(
        to scale: CGFloat = 1.0,
        duration: TimeInterval = 0.2,
        completion: (() -> Void)? = nil
    ) {
        UIView.animate(withDuration: duration) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: scale, y: scale)
        } completion: { _ in
            completion?()
        }
    }
}

// MARK: - Shimmer Animation

extension UIView {
    
    func addShimmerAnimation(
        colors: [CGColor] = UIColor.defaultShimmerColors,
        startPoint: CGPoint = .defaultShimmerStartPoint,
        endPoint: CGPoint = .defaultShimmerEndPoint,
        locations: [NSNumber] = NSNumber.defaultShimmerLocations,
        fromValues: [NSNumber] = NSNumber.defaultShimmerFromValues,
        toValues: [NSNumber] = NSNumber.defaultShimmerToValues,
        duration: CFTimeInterval = .defaultShimmerDuration
    ) {
        let gradient = CALayer
            .shimmerGradient(frame: bounds,
                             colors: colors,
                             startPoint: startPoint,
                             endPoint: endPoint,
                             locations: locations)
        
        gradient
            .addShimmerAnimation(fromValue: fromValues,
                                 toValue: toValues,
                                 duration: duration)
        
        layer.addSublayer(gradient)
    }
    
    func removeShimmerAnimation() {
        guard
            let gradientLayer = layer.sublayers?.first(where: { $0 is CAGradientLayer })
        else { return }
        gradientLayer.removeFromSuperlayer()
    }
}

// MARK: - Affine Transform Animations

extension UIView {
    
    func animateSelection(completion: (() -> Void)?) {
        animateScale(to: 0.9) {
            self.animateScale(completion: completion)
        }
    }
    
    func animateHighlight() {
        animateScale(to: 0.9)
    }
    
    func animateUnhighlight() {
        animateScale()
    }
    
    func animateCellAppearance(
        with translation: CGPoint = .init(x: 0, y: 50),
        alpha: CGFloat = 1,
        duration: TimeInterval = 0.5,
        dampingRatio: CGFloat = 0.9
    ) {
        transform = CGAffineTransform(translationX: translation.x, y: translation.y)
        self.alpha = .zero
        
        let animator = UIViewPropertyAnimator(
            duration: duration,
            dampingRatio: dampingRatio
        ) {
            self.transform = .identity
            self.alpha = alpha
        }
        
        animator.startAnimation()
    }
}
