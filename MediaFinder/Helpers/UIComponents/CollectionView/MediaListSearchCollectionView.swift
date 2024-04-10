import UIKit

// MARK: - Delegates

protocol MediaListSearchCollectionViewDelegate: AnyObject {
    func getMediaSearchList() -> [Media]
}

final class MediaListSearchCollectionView: UICollectionView {
    
    // MARK: - Private Properties
    
    private let params = GeometricParams(
        cellCount: Const.collectionViewCellCount,
        insets: Const.spacingMedium,
        cellSpacing: Const.spacingMedium
    )
    
    // MARK: - Properties
    
    weak var sourceDelegate: MediaListSearchCollectionViewDelegate?
    
    // MARK: - Initialisers
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        backgroundColor = .clear
        
        dataSource = self
        delegate = self
        
        register(MediaListSearchCell.self, forCellWithReuseIdentifier: Const.collectionViewReuseIdentifier)
        
        allowsMultipleSelection = false
        showsVerticalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - DataSource Methods

extension MediaListSearchCollectionView: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        sourceDelegate?.getMediaSearchList().count ?? .zero
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        let cellData = sourceDelegate?.getMediaSearchList()
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: Const.collectionViewReuseIdentifier,
            for: indexPath
        )
        
        guard
            let media = cellData?[indexPath.row],
            let mediaCell = cell as? MediaListSearchCell
        else {
            return UICollectionViewCell()
        }
        
        mediaCell.configure(with: media)
        
        return mediaCell
    }
}

// MARK: - Delegate Methods

extension MediaListSearchCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableWidth / CGFloat(params.cellCount)
        let cellHeight = Const.collectionViewCellHeight
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: params.insets,
            left: params.insets,
            bottom: params.insets,
            right: params.insets
        )
    }
}
