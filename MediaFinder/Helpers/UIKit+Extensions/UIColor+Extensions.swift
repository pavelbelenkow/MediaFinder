import UIKit

// MARK: - Color Manipulation

extension UIColor {
    
    /// Stores default shimmer CG colors array
    static var defaultShimmerColors: [CGColor] {
        [
            mediaBackground.cgColor(multipliedBy: 0.9),
            mediaBackground.cgColor,
            mediaBackground.cgColor(multipliedBy: 0.9)
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
}
