import UIKit

struct ImageColors {
    let background: UIColor
    let primary: UIColor
    let secondary: UIColor
    let detail: UIColor
}

extension UIImage {

    // MARK: - Methods
    
    func getColors(_ completion: @escaping (ImageColors?) -> Void) {
        DispatchQueue.global().async {
            let result = self.getColors()
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
}

private extension UIImage {
    
    struct UIImageColorsCounter {
        let color: Double
        let count: Int
    }
    
    struct Const {
        static let sizeOneHundred: CGSize = CGSize(width: 100, height: 100)
        static let thresholdPercentage: CGFloat = 0.01
    }
    
    // MARK: - Methods
    
    func resizeImage(to newSize: CGSize = Const.sizeOneHundred) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(newSize, false, .zero)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
    func extractColors() -> [UIImageColorsCounter] {
        
        guard
            let resizedImage = resizeImage(),
            let cgImage = resizedImage.cgImage,
            let data = CFDataGetBytePtr(cgImage.dataProvider?.data)
        else { return [] }
        
        let width = cgImage.width
        let height = cgImage.height
        let threshold = Int(CGFloat(height) * Const.thresholdPercentage)
        let imageColors = NSCountedSet(capacity: width * height)
        
        for y in stride(from: .zero, to: height, by: 1) {
            for x in stride(from: .zero, to: width, by: 1) {
                let pixel = (y * cgImage.bytesPerRow) + (x * 4)
                let alpha = data[pixel + 3]
                
                guard alpha >= 127 else { continue }
                
                let red = Double(data[pixel + 2]) * .redGamut
                let green = Double(data[pixel + 1]) * .greenGamut
                let blue = Double(data[pixel])
                let color = red + green + blue
                
                imageColors.add(color)
            }
        }
        
        let sortedColors: [UIImageColorsCounter] = imageColors
            .compactMap { $0 as? Double }
            .map { UIImageColorsCounter(color: $0, count: imageColors.count(for: $0)) }
            .filter { $0.count > threshold }
            .sorted { $0.count > $1.count }
        
        return sortedColors
    }
    
    func findPrimaryColor(from colors: [UIImageColorsCounter], baseColor: Double) -> Double {
        for color in colors where color.color.isSuitableAccent(for: baseColor) {
            return color.color
        }
        return baseColor.isDarkColor ? baseColor.lighter() : baseColor.darker()
    }
    
    func findSecondaryColor(
        from colors: [UIImageColorsCounter],
        baseColor: Double,
        primaryColor: Double
    ) -> Double {
        for color in colors where color.color.isSuitableAccent(for: baseColor) && color.color.isSuitableAccent(for: primaryColor) {
            return color.color
        }
        return primaryColor.isDarkColor ? primaryColor.lighter(by: 40) : primaryColor.darker(by: 40)
    }
    
    func findDetailColor(
        from colors: [UIImageColorsCounter],
        baseColor: Double,
        secondaryColor: Double
    ) -> Double {
        for color in colors where color.color.isSuitableAccent(for: baseColor) && secondaryColor.isDistinct(from: color.color) {
            return color.color
        }
        return baseColor.isDarkColor ? baseColor.lighter(by: 60) : baseColor.darker(by: 60)
    }
    
    func getColors() -> ImageColors? {
        let sortedColors = extractColors()
        var proposed: [Double] = Array(repeating: -1, count: 4)
        
        if let mostFrequentColor = sortedColors.first {
            proposed[0] = mostFrequentColor.color
        }
        
        proposed[1] = findPrimaryColor(from: sortedColors, baseColor: proposed[0])
        proposed[2] = findSecondaryColor(from: sortedColors, baseColor: proposed[0], primaryColor: proposed[1])
        proposed[3] = findDetailColor(from: sortedColors, baseColor: proposed[1], secondaryColor: proposed[2])
        
        return ImageColors(
            background: proposed[0].color,
            primary: proposed[1].color,
            secondary: proposed[2].color,
            detail: proposed[3].color
        )
    }
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
    
    var saturation: Double {
        let maxVal = max(red, max(green, blue))
        let minVal = min(red, min(green, blue))
        return maxVal == .zero ? .zero : (maxVal - minVal) / maxVal
    }
    
    var isVibrant: Bool { saturation >= .minSaturation }
    
    // MARK: - Methods
    
    func isDistinct(from color: Double) -> Bool {
        let redDiff = fabs(red - color.red)
        let greenDiff = fabs(green - color.green)
        let blueDiff = fabs(blue - color.blue)
        return redDiff > .distinctThreshold || greenDiff > .distinctThreshold || blueDiff > .distinctThreshold
    }
    
    func isSuitableAccent(for baseColor: Double) -> Bool {
        isDistinct(from: baseColor) && !isBlackOrWhite && isVibrant
    }
    
    func adjustBrightness(by percentage: CGFloat) -> Double {
        let adjustment = percentage / 100 * 255
        let newRed = min(max(red + adjustment, .zero), 255)
        let newGreen = min(max(green + adjustment, .zero), 255)
        let newBlue = min(max(blue + adjustment, .zero), 255)
        return Double(newRed * .redGamut + newGreen * .greenGamut + newBlue)
    }
    
    func lighter(by percentage: CGFloat = 20.0) -> Double {
        adjustBrightness(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 20.0) -> Double {
        adjustBrightness(by: -abs(percentage))
    }
}
