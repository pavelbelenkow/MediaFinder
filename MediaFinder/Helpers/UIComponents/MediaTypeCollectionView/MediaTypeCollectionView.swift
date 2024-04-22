import UIKit

// MARK: - Delegates

protocol MediaTypeCollectionViewDelegate: AnyObject {
    func didScrollToBottomMediaTypeCell()
    func didTapInnerContentMediaTypeCell(at index: Int)
    func didTapInnerContentFooterRepeatButton()
}

final class MediaTypeCollectionView: UICollectionView {
    
    // MARK: - Override Properties
    
    override var safeAreaInsets: UIEdgeInsets { .zero }
    
    // MARK: - Properties
    
    weak var interactionDelegate: MediaTypeCollectionViewDelegate?
    
    // MARK: - Initialisers
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
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
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Methods

extension MediaTypeCollectionView {
    
    func applySnapshotToMediaTypeCell(with data: [Media], at indexPath: IndexPath) {
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
        3
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
    
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        CGSize(width: bounds.width, height: bounds.height)
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
