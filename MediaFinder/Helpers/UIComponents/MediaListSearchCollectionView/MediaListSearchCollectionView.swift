import UIKit

// MARK: - Delegates

protocol MediaListSearchCollectionViewDelegate: AnyObject {
    func didScrollToBottomCollectionView()
    func didTapMedia(at index: Int)
    func didTapFooterRepeatButton()
}

final class MediaListSearchCollectionView: UICollectionView {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, Media>
    typealias Snapshot = NSDiffableDataSourceSnapshot<Int, Media>
    
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
        setupAppearance()
        makeDataSource()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Private Methods

private extension MediaListSearchCollectionView {
    
    func setupAppearance() {
        backgroundColor = .clear
        
        register(
            MediaListSearchCell.self,
            forCellWithReuseIdentifier: Const.mediaListSearchCellReuseIdentifier
        )
        
        register(
            MediaListSearchFooterView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
            withReuseIdentifier: Const.mediaListSearchFooterReuseIdentifier
        )
        
        allowsMultipleSelection = false
        showsVerticalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        
        delegate = self
    }
    
    func makeDataSource() {
        diffableDataSource = DataSource(
            collectionView: self,
            cellProvider: { collectionView, indexPath, media in
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: Const.mediaListSearchCellReuseIdentifier,
                    for: indexPath
                ) as? MediaListSearchCell
                
                cell?.configure(with: media)
                
                return cell
            }
        )
        
        diffableDataSource?
            .supplementaryViewProvider = { collectionView, kind, indexPath in
                let footerView = collectionView.dequeueReusableSupplementaryView(
                    ofKind: kind,
                    withReuseIdentifier: Const.mediaListSearchFooterReuseIdentifier,
                    for: indexPath
                ) as? MediaListSearchFooterView
                
                footerView?.updateStackView(for: .idle, isEmptyResults: true)
                footerView?.delegate = self
                
                return footerView
            }
    }
}

// MARK: - Methods

extension MediaListSearchCollectionView {
    
    func applySnapshot(for mediaList: [Media]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.zero])
        snapshot.appendItems(mediaList)
        diffableDataSource?.apply(snapshot, animatingDifferences: true)
    }
    
    func updateFooterView(for state: State, isEmptyResults: Bool) {
        guard
            let footerView = visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionFooter)
                .first as? MediaListSearchFooterView
        else { return }
        
        footerView.updateStackView(for: state, isEmptyResults: isEmptyResults)
    }
}

// MARK: - Delegate Methods

extension MediaListSearchCollectionView: UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            interactionDelegate?.didScrollToBottomCollectionView()
        }
    }
    
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForFooterInSection section: Int
    ) -> CGSize {
        CGSize(width: collectionView.bounds.width, height: Const.spacingOneHundred)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        ViewAnimator.shared.animateSelection(for: cell) { [weak self] in
            self?.interactionDelegate?.didTapMedia(at: indexPath.item)
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

// MARK: - MediaListSearchFooterViewDelegate Methods

extension MediaListSearchCollectionView: MediaListSearchFooterViewDelegate {
    
    func didTapFooterRepeatButton() {
        interactionDelegate?.didTapFooterRepeatButton()
    }
}
