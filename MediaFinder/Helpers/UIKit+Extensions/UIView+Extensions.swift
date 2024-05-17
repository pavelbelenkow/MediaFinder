import UIKit

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
    
    func animateTextViewInteraction(openURL url: URL) {
        UIView.animate(withDuration: 0.25) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.transform = .identity
            }
            
            UIApplication.shared.open(url)
        }
    }
    
    func animateSelection(_ completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.transform = .identity
            }
            
            completion?()
        }
    }
    
    func animateHighlight() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    func animateUnhighlight() {
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.transform = .identity
        }
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
