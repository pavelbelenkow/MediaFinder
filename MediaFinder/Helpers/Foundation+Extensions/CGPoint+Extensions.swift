import Foundation

extension CGPoint {
    
    /// Stores default shimmer start point `(0, 0)`
    static var defaultShimmerStartPoint: Self { .zero }
    
    /// Stores default shimmer end point `(1, 1)`
    static var defaultShimmerEndPoint: Self { .init(x: 1.0, y: 1.0) }
}
