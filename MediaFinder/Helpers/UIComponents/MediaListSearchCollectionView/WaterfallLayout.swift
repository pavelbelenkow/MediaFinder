import UIKit

final class WaterfallLayout {
    
    private let numberOfColumns: Int
    private let itemRatios: [CGFloat]
    private let spacing: CGFloat
    private let contentWidth: CGFloat
    
    private var padding: CGFloat { spacing / 2 }
    private var insets: NSDirectionalEdgeInsets {
        .init(top: padding, leading: padding, bottom: padding, trailing: padding)
    }
    
    private lazy var frames: [CGRect] = {
        calculateFrames()
    }()
    
    private lazy var sectionHeight: CGFloat = {
        frames.map(\.maxY).max() ?? .zero + insets.bottom
    }()
    
    private lazy var layoutGroup: NSCollectionLayoutGroup = {
        let size = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(sectionHeight)
        )
        
        return NSCollectionLayoutGroup.custom(layoutSize: size) { _ in
            self.frames.map { .init(frame: $0) }
        }
    }()
    
    var layoutSection: NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: layoutGroup)
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        
        section.boundarySupplementaryItems = [footer]
        section.contentInsets = .init(top: .zero, leading: padding, bottom: .zero, trailing: padding)
        return section
    }
    
    init(
        columnsCount: Int,
        itemRatios: [CGFloat],
        spacing: CGFloat,
        contentWidth: CGFloat
    ) {
        self.numberOfColumns = columnsCount
        self.itemRatios = itemRatios
        self.spacing = spacing
        self.contentWidth = contentWidth
    }
}

private extension WaterfallLayout {
    
    func calculateFrames() -> [CGRect] {
        
        let columnWidth = (contentWidth - insets.leading - insets.trailing) / CGFloat(numberOfColumns)
        let xOffsets = (0..<numberOfColumns).map { CGFloat($0) * columnWidth }
        var yOffsets: [CGFloat] = .init(repeating: .zero, count: numberOfColumns)
        var currentColumn = 0
        var frames: [CGRect] = []
        var contentHeight: CGFloat = .zero
        
        for item in 0..<itemRatios.count {
            let ratio = itemRatios[item]
            let descriptionHeight = Const.spacingOneHundred
            
            let frame = CGRect(
                x: xOffsets[currentColumn],
                y: yOffsets[currentColumn],
                width: columnWidth,
                height: (columnWidth / ratio) + descriptionHeight
            ).insetBy(dx: padding, dy: padding)
            
            frames.append(frame)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffsets[currentColumn] = frame.maxY
            currentColumn = yOffsets.indexOfMinElement ?? .zero
        }
        
        return frames
    }
}

private extension Array where Element: Comparable {
    
    var indexOfMinElement: Int? {
        guard count > .zero else { return nil }
        
        var min = first
        var index = 0
        
        indices.forEach {
            let current = self[$0]
            
            if let minimum = min, current < minimum {
                min = current
                index = $0
            }
        }
        
        return index
    }
}

private extension CGRect {
    
    func setHeight(ratio: CGFloat) -> CGRect {
        .init(x: minX, y: minY, width: width, height: height / ratio)
    }
}
