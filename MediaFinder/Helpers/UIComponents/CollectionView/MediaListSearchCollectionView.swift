import UIKit

// MARK: - Delegates

protocol MediaListSearchCollectionViewDelegate: AnyObject {
    func getMediaSearchList() -> [Media]
    func didTapMedia(at index: Int)
}

final class MediaListSearchCollectionView: UICollectionView {
    
    enum Section {
        case main
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Media>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Media>
    
    // MARK: - Private Properties
    
    private let params = GeometricParams(
        cellCount: Const.collectionViewCellCount,
        insets: Const.spacingMedium,
        cellSpacing: Const.spacingMedium
    )
    
    private var diffableDataSource: DataSource?
    
    // MARK: - Properties
    
    weak var interactionDelegate: MediaListSearchCollectionViewDelegate?
    
    // MARK: - Initialisers
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        backgroundColor = .clear
        
        register(MediaListSearchCell.self, forCellWithReuseIdentifier: Const.collectionViewReuseIdentifier)
        
        allowsMultipleSelection = false
        showsVerticalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        
        delegate = self
        
        makeDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods

private extension MediaListSearchCollectionView {
    
    func makeDataSource() {
        diffableDataSource = DataSource(
            collectionView: self,
            cellProvider: { collectionView, indexPath, media in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: Const.collectionViewReuseIdentifier,
                    for: indexPath
                ) as? MediaListSearchCell
                
                cell?.configure(with: media)
                
                return cell
            }
        )
    }
}

// MARK: - Methods

extension MediaListSearchCollectionView {
    
    func applySnapshot(for mediaList: [Media]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(mediaList)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        interactionDelegate?.didTapMedia(at: indexPath.row)
    }
}
