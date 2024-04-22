import UIKit

// MARK: - Delegates

protocol MediaTypeCellDelegate: AnyObject {
    func didScrollToBottomInnerContent()
    func didTapInnerContentCell(at index: Int)
    func didTapInnerContentFooterRepeatButton()
}

final class MediaTypeCell: UICollectionViewCell {
    
    // MARK: - Private Properties
    
    private lazy var collectionView: MediaListSearchCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = MediaListSearchCollectionView(frame: .zero, collectionViewLayout: layout)
        view.interactionDelegate = self
        return view
    }()
    
    // MARK: - Properties
    
    weak var delegate: MediaTypeCellDelegate?
    
    // MARK: - Initialisers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI

private extension MediaTypeCell {
    
    func setupAppearance() {
        contentView.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ])
    }
}

// MARK: - Methods

extension MediaTypeCell {
    
    func applySnapshotToInnerContent(with data: [Media]) {
        collectionView.applySnapshot(for: data)
    }
    
    func updateInnerContentFooter(for state: State, isEmptyResults: Bool) {
        collectionView.updateFooterView(for: state, isEmptyResults: isEmptyResults)
    }
}

// MARK: - MediaListSearchCollectionViewDelegate Methods

extension MediaTypeCell: MediaListSearchCollectionViewDelegate {
    
    func didScrollToBottomCollectionView() {
        delegate?.didScrollToBottomInnerContent()
    }
    
    func didTapMedia(at index: Int) {
        delegate?.didTapInnerContentCell(at: index)
    }
    
    func didTapFooterRepeatButton() {
        delegate?.didTapInnerContentFooterRepeatButton()
    }
}
