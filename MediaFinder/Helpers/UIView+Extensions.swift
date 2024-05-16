import UIKit

// MARK: - Shimmer Animation

extension UIView {
    
    func addShimmerAnimation(
        colors: [CGColor] = [
            UIColor.mediaBackground.cgColor(multipliedBy: 0.9),
            UIColor.mediaBackground.cgColor,
            UIColor.mediaBackground.cgColor(multipliedBy: 0.9)
        ],
        startPoint: CGPoint = CGPoint(x: 0.0, y: 0.0),
        endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0),
        locations: [NSNumber] = [0.0, 0.5, 1.0],
        fromValues: [NSNumber] = [-1.0, -0.5, 0.0],
        toValues: [NSNumber] = [1.0, 1.5, 2.0],
        duration: CFTimeInterval = 1.5
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
