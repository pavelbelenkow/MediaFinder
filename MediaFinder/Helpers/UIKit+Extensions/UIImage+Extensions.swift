import UIKit

struct ImageColors {
    let background: UIColor
    let primary: UIColor
    let secondary: UIColor
    let detail: UIColor
}

private extension Double {
    
    // MARK: - Static Properties
    
    static let redGamut: Double = 1_000_000
    static let greenGamut: Double = 1000
    static let blueGamut: Double = 1000
    
    static let redMultiplier: Double = 0.299
    static let greenMultiplier: Double = 0.587
    static let blueMultiplier: Double = 0.114
    static let darkColorThreshold: Double = 255 * (73 / 100)
    
    static let whiteThreshold: Double = 255 * (91 / 100)
    static let blackThreshold: Double = 255 * (9 / 100)
    
    static let distinctThreshold: Double = 255 * (25 / 100)
    
    static let minSaturation: Double = 0.15
    
    // MARK: - Properties
    
    var red: Double { floor(self / .redGamut) }
    var green: Double { floor((self / .greenGamut).truncatingRemainder(dividingBy: .greenGamut)) }
    var blue: Double { floor(truncatingRemainder(dividingBy: .blueGamut)) }
    
    var color: UIColor {
        UIColor(
            red: CGFloat(red / 255),
            green: CGFloat(green / 255),
            blue: CGFloat(blue / 255),
            alpha: 1.0
        )
    }
    
    var isBlackOrWhite: Bool {
        (red > .whiteThreshold && green > .whiteThreshold && blue > .whiteThreshold) ||
        (red < .blackThreshold && green < .blackThreshold && blue < .blackThreshold)
    }
    
    var isDarkColor: Bool {
        let luminance = red * .redMultiplier + green * .greenMultiplier + blue * .blueMultiplier
        return luminance < .darkColorThreshold
    }
    
    // MARK: - Methods
    
    func isDistinct(from color: Double) -> Bool {
        let redDiff = fabs(red - color.red)
        let greenDiff = fabs(green - color.green)
        let blueDiff = fabs(blue - color.blue)
        return redDiff > .distinctThreshold || greenDiff > .distinctThreshold || blueDiff > .distinctThreshold
    }
}
