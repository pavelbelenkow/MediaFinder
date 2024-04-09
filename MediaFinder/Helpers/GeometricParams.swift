import Foundation

struct GeometricParams {
    let cellCount: Int
    let insets: CGFloat
    let cellSpacing: CGFloat
    let paddingWidth: CGFloat
    
    init(cellCount: Int,
         insets: CGFloat,
         cellSpacing: CGFloat
    ) {
        self.cellCount = cellCount
        self.insets = insets
        self.cellSpacing = cellSpacing
        self.paddingWidth = (insets * 2) + CGFloat(cellCount - 1) * cellSpacing
    }
}
