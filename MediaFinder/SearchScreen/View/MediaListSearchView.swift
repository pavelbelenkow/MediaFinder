import UIKit

// MARK: - Delegates

protocol MediaListSearchViewDelegate: AnyObject {
    func didSelectMediaType(for index: Int)
    func didScrollToBottomCollectionView()
    func didTapInnerContentCollectionView(at index: Int)
    func didTapFooterRepeatButton()
    func getRecentSearches() -> [String]
    func didTapRecentTerm(at index: Int)
}

final class MediaListSearchView: UIView {
    
    // MARK: - Private Properties
    
    private lazy var mediaTypePageControl: MediaTypePageControl = {
        let control = MediaTypePageControl()
        control.delegate = self
        return control
    }()
    
    private lazy var mediaTypeCollectionView: MediaTypeCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = MediaTypeCollectionView(frame: .zero, collectionViewLayout: layout)
        view.interactionDelegate = self
        return view
    }()
    
    private lazy var recentSearchTableView: MediaListRecentSearchTableView = {
        let view = MediaListRecentSearchTableView()
        view.isHidden = true
        view.interactionDelegate = self
        return view
    }()
    
    // MARK: - Properties
    
    weak var delegate: MediaListSearchViewDelegate?
    
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

private extension MediaListSearchView {
    
    func setupAppearance() {
        setupBackgroundColor()
        setupMediaTypePageControl()
        setupMediaTypeCollectionView()
        setupRecentSearchTableView()
    }
    
    func setupBackgroundColor() {
        backgroundColor = .mediaBackground
    }
    
    func setupMediaTypePageControl() {
        addSubview(mediaTypePageControl)
        
        NSLayoutConstraint.activate([
            mediaTypePageControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, 
                                                         constant: Const.spacingThirty),
            mediaTypePageControl.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                                          constant: Const.spacingMedium)
        ])
    }
    
    func setupMediaTypeCollectionView() {
        addSubview(mediaTypeCollectionView)
        
        NSLayoutConstraint.activate([
            mediaTypeCollectionView.topAnchor.constraint(equalTo: mediaTypePageControl.bottomAnchor,
                                                         constant: Const.spacingExtraSmall),
            mediaTypeCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
            mediaTypeCollectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            mediaTypeCollectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func setupRecentSearchTableView() {
        addSubview(recentSearchTableView)
        
        NSLayoutConstraint.activate([
            recentSearchTableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            recentSearchTableView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            recentSearchTableView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            recentSearchTableView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
    }
}

// MARK: - Methods

extension MediaListSearchView {
    
    func reloadCollectionView(with data: [Media], and type: EntityType) {
        switch type {
        case .all:
            mediaTypeCollectionView.applySnapshotToMediaTypeCell(with: data, at: .zero)
        case .movie:
            mediaTypeCollectionView.applySnapshotToMediaTypeCell(with: data, at: 1)
        case .song:
            mediaTypeCollectionView.applySnapshotToMediaTypeCell(with: data, at: 2)
        }
    }
    
    func reloadTableView() {
        recentSearchTableView.reloadData()
    }
    
    func updateUI(for state: State, isEmptyResults: Bool) {
        for item in 0..<mediaTypeCollectionView.numberOfItems(inSection: .zero) {
            let indexPath = IndexPath(item: item, section: .zero)
            mediaTypeCollectionView.updateMediaTypeCellFooter(
                for: state,
                isEmptyResults: isEmptyResults,
                at: indexPath
            )
        }
    }
    
    func updateCollectionsVisibility(_ state: Bool) {
        recentSearchTableView.isHidden = state
        mediaTypeCollectionView.isHidden = !state
    }
}

// MARK: - MediaTypePageControlDelegate Methods

extension MediaListSearchView: MediaTypePageControlDelegate {
    
    func change(to index: Int) {
        let indexPath = IndexPath(item: index, section: .zero)
        delegate?.didSelectMediaType(for: index)
        mediaTypeCollectionView.scrollToItem(
            at: indexPath,
            at: .centeredHorizontally,
            animated: true
        )
    }
}

// MARK: - MediaTypeCollectionViewDelegate Methods

extension MediaListSearchView: MediaTypeCollectionViewDelegate {
    
    func didScrollHorizontallyCollectionView(to index: Int) {
        mediaTypePageControl.handleSelectionChange(to: index)
    }
    
    func didScrollToBottomMediaTypeCell() {
        delegate?.didScrollToBottomCollectionView()
    }
    
    func didTapInnerContentMediaTypeCell(at index: Int) {
        delegate?.didTapInnerContentCollectionView(at: index)
    }
    
    func didTapInnerContentFooterRepeatButton() {
        delegate?.didTapFooterRepeatButton()
    }
}

// MARK: - MediaListRecentSearchTableViewDelegate Methods

extension MediaListSearchView: MediaListRecentSearchTableViewDelegate {
    
    func getRecentSearches() -> [String] {
        delegate?.getRecentSearches() ?? []
    }
    
    func didTapRecentTerm(at index: Int) {
        delegate?.didTapRecentTerm(at: index)
    }
}
