import UIKit

// MARK: - Delegates

protocol WaterfallLayoutDelegate: AnyObject {
    func collectionView(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        with width: CGFloat) -> CGFloat
}

final class WaterfallLayout: UICollectionViewLayout {
    
    // MARK: - Private Properties
    
    private var columnsCount: Int
    private var cellPadding: CGFloat
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    private var contentHeight: CGFloat = .zero
    private var contentWidth: CGFloat {
        guard let collectionView else { return .zero }
        
        let insets = collectionView.contentInset
        return collectionView.bounds.width - (insets.left + insets.right)
    }
    
    // MARK: - Properties
    
    weak var delegate: WaterfallLayoutDelegate?
    
    // MARK: - Initialisers
    
    init(columnsCount: Int = 2, cellPadding: CGFloat = 4) {
        self.columnsCount = columnsCount
        self.cellPadding = cellPadding
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden Properties
    
    override var collectionViewContentSize: CGSize { .init(width: contentWidth, height: contentHeight) }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        cache.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cache.first { $0.indexPath == indexPath }
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        cache.first { $0.indexPath == indexPath && $0.representedElementKind == elementKind }
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
    func clearCacheAndContentHeight() {
        cache.removeAll()
        contentHeight = .zero
    }
    
    func calculateItemAttributes(
        collectionView: UICollectionView,
        columnWidth: CGFloat,
        xOffsets: [CGFloat],
        yOffsets: inout [CGFloat]
    ) {
        var column: Int = .zero
        
        for item in .zero..<collectionView.numberOfItems(inSection: .zero) {
            let indexPath = IndexPath(item: item, section: .zero)
            
            let height = calculateItemHeight(
                collectionView: collectionView,
                for: indexPath,
                columnWidth: columnWidth
            )
            
            let frame = CGRect(
                x: xOffsets[column],
                y: yOffsets[column],
                width: columnWidth,
                height: height
            ).insetBy(dx: cellPadding, dy: cellPadding)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY)
            yOffsets[column] = yOffsets[column] + height
            
            column = column < (columnsCount - 1) ? (column + 1) : 0
        }
    }
    
    func calculateItemHeight(
        collectionView: UICollectionView,
        for indexPath: IndexPath,
        columnWidth: CGFloat
    ) -> CGFloat {
        let width = columnWidth - cellPadding * 2
        let imageHeight = delegate?.collectionView(
            collectionView,
            heightForItemAt: indexPath,
            with: width
        ) ?? .zero
        
        return cellPadding * 2 + imageHeight
    }
    
    func calculateFooterAttributes(for collectionView: UICollectionView) {
        let indexPath = IndexPath(item: .zero, section: .zero)
        let attributes = UICollectionViewLayoutAttributes(
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            with: indexPath
        )
        
        let footerHeight = Const.spacingOneHundred
        let footerWidth = collectionView.bounds.width
        let frame = CGRect(
            x: .zero,
            y: contentHeight,
            width: footerWidth,
            height: footerHeight
        )
        
        attributes.frame = frame
        cache.append(attributes)
        contentHeight += footerHeight
    }
}
