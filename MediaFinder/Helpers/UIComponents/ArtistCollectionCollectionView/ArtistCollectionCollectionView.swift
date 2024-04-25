import UIKit

// MARK: - Delegates

protocol ArtistCollectionCollectionViewDelegate: AnyObject {
    func didTapCollection(at index: Int)
}

final class ArtistCollectionCollectionView: UICollectionView {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Media>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Media>
    
    // MARK: - Private Properties
    
    private let params = GeometricParams(
        cellCount: 1,
        insets: Const.spacingMedium,
        cellSpacing: Const.spacingMedium
    )
    
    private var diffableDataSource: DataSource?
    
    // MARK: - Properties
    
    weak var interactionDelegate: ArtistCollectionCollectionViewDelegate?
    
    // MARK: - Initialisers
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        setupAppearance()
        makeDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods

private extension ArtistCollectionCollectionView {
    
    func setupAppearance() {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
        }
        
        backgroundColor = .clear
        
        register(
            ArtistCollectionCell.self,
            forCellWithReuseIdentifier: Const.artistCollectionCellReuseIdentifier
        )
        
        allowsMultipleSelection = false
        showsHorizontalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        
        delegate = self
    }
    
    func makeDataSource() {
        diffableDataSource = DataSource(
            collectionView: self,
            cellProvider: { collectionView, indexPath, collection in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: Const.artistCollectionCellReuseIdentifier,
                    for: indexPath
                ) as? ArtistCollectionCell
                
                cell?.configure(with: collection)
                
                return cell
            }
        )
    }
}

// MARK: - Methods

extension ArtistCollectionCollectionView {
    
    func applySnapshot(for collection: [Media]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.zero])
        snapshot.appendItems(collection)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - Delegate Methods

extension ArtistCollectionCollectionView: UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        cell.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.5) {
            cell.transform = .identity
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let availableWidth = collectionView.frame.width - params.paddingWidth
        let cellWidth = availableWidth / 2
        let cellHeight = collectionView.frame.height - params.paddingWidth
        
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        UIEdgeInsets(
            top: params.insets,
            left: Const.spacingOneHundred,
            bottom: params.insets,
            right: params.insets
        )
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        params.cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        ViewAnimator.shared.animateSelection(for: cell) { [weak self] in
            self?.interactionDelegate?.didTapCollection(at: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        ViewAnimator.shared.animateHighlight(for: cell)
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        ViewAnimator.shared.animateUnhighlight(for: cell)
    }
}
