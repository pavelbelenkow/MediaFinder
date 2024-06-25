import UIKit

// MARK: - Delegates

protocol MediaTypeCollectionViewDelegate: AnyObject {
    func didScrollHorizontallyCollectionView(with offset: CGFloat)
    func didScrollHorizontallyCollectionView(to index: Int)
    func didScrollToBottomMediaTypeCell()
    func didTapInnerContentMediaTypeCell(at index: Int)
    func didTapInnerContentFooterRepeatButton()
}

final class MediaTypeCollectionView: UICollectionView {
    
    // MARK: - Private Properties
    
    private var previousBounds: CGRect = .zero
    
    // MARK: - Properties
    
    weak var interactionDelegate: MediaTypeCollectionViewDelegate?
    
    // MARK: - Initialisers
    
    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout Overrides
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard
            let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout,
            bounds != previousBounds
        else { return }
        
        previousBounds = bounds
        flowLayout.invalidateLayout()
    }
}

// MARK: - Setup UI

private extension MediaTypeCollectionView {
    
    func setupAppearance() {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = .zero
        }
        
        backgroundColor = .clear
        
        register(
            MediaTypeCell.self,
            forCellWithReuseIdentifier: Const.mediaTypeCellReuseIdentifier
        )
        
        allowsSelection = false
        isPagingEnabled = true
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        
        dataSource = self
        delegate = self
    }
}

// MARK: - Methods

extension MediaTypeCollectionView {
    
    func applySnapshotToMediaTypeCell(with data: [Media], at index: Int) {
        let indexPath = IndexPath(item: index, section: .zero)
        guard let cell = cellForItem(at: indexPath) as? MediaTypeCell else { return }
        cell.applySnapshotToInnerContent(with: data)
    }
    
    func updateMediaTypeCellFooter(
        for state: State,
        isEmptyResults: Bool,
        at indexPath: IndexPath
    ) {
        guard let cell = cellForItem(at: indexPath) as? MediaTypeCell else { return }
        cell.updateInnerContentFooter(for: state, isEmptyResults: isEmptyResults)
    }
}

// MARK: - DataSource Methods

extension MediaTypeCollectionView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        Const.mediaTypeButtonTitles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Const.mediaTypeCellReuseIdentifier,
                for: indexPath
            ) as? MediaTypeCell
        else { return UICollectionViewCell() }
        
        cell.delegate = self
        
        return cell
    }
}

// MARK: - Delegate Methods

extension MediaTypeCollectionView: UICollectionViewDelegateFlowLayout {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentWidth = scrollView.frame.width * 2
        var offset = scrollView.contentOffset.x
        
        if offset >= .zero && offset <= contentWidth {
            offset /= 5.4
            interactionDelegate?.didScrollHorizontallyCollectionView(with: offset)
        }
    }
    
    func scrollViewWillEndDragging(
        _ scrollView: UIScrollView,
        withVelocity velocity: CGPoint,
        targetContentOffset: UnsafeMutablePointer<CGPoint>
    ) {
        let index = Int(targetContentOffset.pointee.x / scrollView.frame.width)
        interactionDelegate?.didScrollHorizontallyCollectionView(to: index)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        frame.size
    }
}

// MARK: - MediaTypeCellDelegate Methods

extension MediaTypeCollectionView: MediaTypeCellDelegate {
    
    func didScrollToBottomInnerContent() {
        interactionDelegate?.didScrollToBottomMediaTypeCell()
    }
    
    func didTapInnerContentCell(at index: Int) {
        interactionDelegate?.didTapInnerContentMediaTypeCell(at: index)
    }
    
    func didTapInnerContentFooterRepeatButton() {
        interactionDelegate?.didTapInnerContentFooterRepeatButton()
    }
}
