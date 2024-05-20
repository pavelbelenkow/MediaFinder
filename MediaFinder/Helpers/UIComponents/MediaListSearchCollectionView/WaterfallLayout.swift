import UIKit

final class WaterfallLayout: UICollectionViewCompositionalLayout {
    
    // MARK: - Private Properties
    
    private var columnsCount: Int
    private var spacing: CGFloat
    private var contentWidth: CGFloat
    private var itemRatios: [CGFloat]
    
    
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

// MARK: - Private Methods

private extension WaterfallLayout {
    
    static func createLayoutSection(
        columnsCount: Int,
        spacing: CGFloat,
        contentWidth: CGFloat,
        itemRatios: [CGFloat]
    ) -> NSCollectionLayoutSection {
        let padding: CGFloat = spacing / 2
        let insets = NSDirectionalEdgeInsets(top: padding, leading: padding, bottom: padding, trailing: padding)
        
        let columnWidth = (contentWidth - insets.leading - insets.trailing) / CGFloat(columnsCount)
        let xOffsets = (0..<columnsCount).map { CGFloat($0) * columnWidth }
        var yOffsets: [CGFloat] = .init(repeating: .zero, count: columnsCount)
        var frames: [CGRect] = []
        var currentColumn = 0
        
        for ratio in itemRatios {
            let descriptionHeight: CGFloat = Const.spacingOneHundred
            let frame = CGRect(
                x: xOffsets[currentColumn],
                y: yOffsets[currentColumn],
                width: columnWidth,
                height: (columnWidth / ratio) + descriptionHeight
            ).insetBy(dx: padding, dy: padding)
            
            frames.append(frame)
            yOffsets[currentColumn] = frame.maxY
            currentColumn = yOffsets.indexOfMinElement ?? .zero
        }
        
        let sectionHeight = frames.map(\.maxY).max() ?? .zero + insets.bottom
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(sectionHeight)
        )
        let group = NSCollectionLayoutGroup.custom(layoutSize: groupSize) { environment in
            frames.map { NSCollectionLayoutGroupCustomItem(frame: $0) }
        }
        
        let footerSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .absolute(100)
        )
        let footer = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerSize,
            elementKind: UICollectionView.elementKindSectionFooter,
            alignment: .bottom
        )
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = insets
        section.boundarySupplementaryItems = [footer]
        
        return section
    }
}

private extension Array where Element: Comparable {
    
    var indexOfMinElement: Int? {
        guard let minElement = self.min() else { return nil }
        return firstIndex(of: minElement)
    }
}
