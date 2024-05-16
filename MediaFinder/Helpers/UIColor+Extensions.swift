import UIKit

// MARK: - Color Manipulation

extension UIColor {
    
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
