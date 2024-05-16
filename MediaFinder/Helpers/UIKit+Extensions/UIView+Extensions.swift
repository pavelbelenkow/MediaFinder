import UIKit

// MARK: - Shimmer Animation

extension UIView {
    
    func addShimmerAnimation(
        startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0),
        endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0),
        locations: [NSNumber] = [0.0, 0.5, 1.0],
        fromValues: [NSNumber] = [-1.0, -0.5, 0.0],
        toValues: [NSNumber] = [1.0, 1.5, 2.0],
        duration: CFTimeInterval = 1.5
        colors: [CGColor] = UIColor.defaultShimmerColors,
    ) {
        let gradient = CAGradientLayer()
        gradient.frame = bounds
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        gradient.locations = locations
        gradient.colors = colors
        layer.addSublayer(gradient)
        
        let animation = CABasicAnimation(keyPath: Const.locationsKeyPath)
        animation.fromValue = fromValues
        animation.toValue = toValues
        animation.duration = duration
        animation.repeatCount = .infinity
        animation.isRemovedOnCompletion = false
        gradient.add(animation, forKey: Const.shimmerAnimationKey)
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
    
    func animateCellAppearance() {
        transform = CGAffineTransform(translationX: 0, y: 50)
        alpha = .zero
        
        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.9) {
            self.transform = .identity
            self.alpha = 1
        }
        
        animator.startAnimation()
    }
}
