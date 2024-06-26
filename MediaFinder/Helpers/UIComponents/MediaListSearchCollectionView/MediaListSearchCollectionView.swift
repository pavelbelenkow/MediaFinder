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
    
    private var diffableDataSource: DataSource?
    
    // MARK: - Properties
    
    weak var interactionDelegate: MediaListSearchCollectionViewDelegate?
    
    // MARK: - Initialisers
    
    init() {
        let layout = WaterfallLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
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
        
        if let layout = collectionViewLayout as? WaterfallLayout {
            layout.delegate = self
        }
        
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
            let footerView = visibleSupplementaryViews(
                ofKind: UICollectionView.elementKindSectionFooter
            ).first as? MediaListSearchFooterView
        else { return }
        
        footerView.updateStackView(for: state, isEmptyResults: isEmptyResults)
    }
}

// MARK: - Layout Delegate Methods

extension MediaListSearchCollectionView: WaterfallLayoutDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        heightForItemAt indexPath: IndexPath,
        with width: CGFloat
    ) -> CGFloat {
        guard
            let media = diffableDataSource?.itemIdentifier(for: indexPath)
        else { return .zero }
        
        return width / media.imageRatio() + Const.spacingOneHundred
    }
}

// MARK: - Delegate Methods

extension MediaListSearchCollectionView: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > contentHeight - height {
            interactionDelegate?.didScrollToBottomCollectionView()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        
        cell.animateSelection {
            self.interactionDelegate?.didTapMedia(at: indexPath.item)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        cell.animateHighlight()
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        cell.animateUnhighlight()
    }
}

// MARK: - MediaListSearchFooterViewDelegate Methods

extension MediaListSearchCollectionView: MediaListSearchFooterViewDelegate {
    
    func didTapFooterRepeatButton() {
        interactionDelegate?.didTapFooterRepeatButton()
    }
}
