import Foundation

extension NSNumber {
    
    /// Stores default shimmer locations `[0.0, 0.5, 1.0]`
    static var defaultShimmerLocations: [NSNumber] { [0.0, 0.5, 1.0] }
    
    /// Stores default shimmer from values `[-1.0, -0.5, 0.0]`
    static var defaultShimmerFromValues: [NSNumber] { [-1.0, -0.5, 0.0] }
    
    /// Stores default shimmer to values `[1.0, 1.5, 2.0]`
    static var defaultShimmerToValues: [NSNumber] { [1.0, 1.5, 2.0] }
}
