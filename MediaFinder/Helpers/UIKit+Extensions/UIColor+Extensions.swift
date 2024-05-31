import UIKit

// MARK: - Color Manipulation

extension UIColor {
    
    /// Stores default shimmer CGColor array
    static var defaultShimmerColors: [CGColor] {
        [
            mediaBackground.cgColor(multipliedBy: 0.95),
            mediaBackground.cgColor(multipliedBy: 1.1),
            mediaBackground.cgColor(multipliedBy: 0.95)
        ]
    }
    
    /// Stores default shimmer border CGColor array
    static var defaultShimmerBorderColors: [CGColor] {
        [
            mediaBackground.cgColor,
            mediaBackground.cgColor(multipliedBy: 1.8),
            mediaBackground.cgColor
        ]
    }
    
    /// Returns a CGColor with each of its components (except alpha) multiplied by the specified multiplier.
    func cgColor(multipliedBy multiplier: CGFloat) -> CGColor {
        
        var red: CGFloat = .zero
        var green: CGFloat = .zero
        var blue: CGFloat = .zero
        var alpha: CGFloat = .zero
        
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        red *= multiplier
        green *= multiplier
        blue *= multiplier
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor
    }
    
    /// Calculates the Euclidean distance between two colors.
    func distance(to color: UIColor) -> CGFloat {
        var r1: CGFloat = .zero
        var g1: CGFloat = .zero
        var b1: CGFloat = .zero
        var a1: CGFloat = .zero
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        
        var r2: CGFloat = .zero
        var g2: CGFloat = .zero
        var b2: CGFloat = .zero
        var a2: CGFloat = .zero
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return sqrt(pow(r1 - r2, 2) + pow(g1 - g2, 2) + pow(b1 - b2, 2) + pow(a1 - a2, 2))
    }
}
