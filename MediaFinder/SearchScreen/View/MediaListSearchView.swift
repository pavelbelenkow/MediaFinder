import UIKit

// MARK: - Delegates

protocol MediaListSearchViewDelegate: AnyObject {
    func collectionViewDidScrollToBottom()
    func getRecentSearches() -> [String]
    func didTapRecentTerm(at index: Int)
    func didTapMedia(at index: Int)
    func didSelectMediaType(for index: Int)
    func didTapRepeatButton()
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
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = .zero
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
    
    func reloadCollectionView(with data: [Media]) {
        mediaListCollectionView.applySnapshot(for: data)
    }
    
    func reloadTableView() {
        recentSearchTableView.reloadData()
    }
    
    func updateUI(for state: State, isEmptyResults: Bool) {
        mediaListCollectionView.updateFooterView(for: state, isEmptyResults: isEmptyResults)
    }
    
    func updateCollectionsVisibility(_ state: Bool) {
        recentSearchTableView.isHidden = state
        mediaListCollectionView.isHidden = !state
    }
}

// MARK: - MediaTypePageControlDelegate Methods

extension MediaListSearchView: MediaTypePageControlDelegate {
    
    func change(to index: Int) {
        delegate?.didSelectMediaType(for: index)
    }
}

// MARK: - MediaListSearchCollectionViewDelegate Methods

extension MediaListSearchView: MediaListSearchCollectionViewDelegate {
    
    func collectionViewDidScrollToBottom() {
        delegate?.collectionViewDidScrollToBottom()
    }
    
    func didTapMedia(at index: Int) {
        delegate?.didTapMedia(at: index)
    }
    
    func didTapRepeatButton() {
        delegate?.didTapRepeatButton()
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
