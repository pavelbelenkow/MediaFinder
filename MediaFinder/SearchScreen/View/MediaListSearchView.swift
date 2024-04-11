import UIKit

// MARK: - Delegates

protocol MediaListSearchViewDelegate: AnyObject {
    func getSearchList() -> [Media]
    func getRecentSearches() -> [String]
    func didTapRecentTerm(at index: Int)
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
    
    private lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mediaListCollectionView: MediaListSearchCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = MediaListSearchCollectionView(frame: .zero, collectionViewLayout: layout)
        view.sourceDelegate = self
        return view
    }()
    
    private lazy var recentSearchTableView: MediaListRecentSearchTableView = {
        let view = MediaListRecentSearchTableView()
        view.isHidden = true
        view.interactionDelegate = self
        return view
    }()
    
    private lazy var statefulStackView: StatefulStackView = {
        let view = StatefulStackView()
        view.delegate = self
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
        setupContainerView()
        setupMediaListCollectionView()
        setupRecentSearchTableView()
        setupStatefulStackView()
    }
    
    func setupBackgroundColor() {
        backgroundColor = .mediaBackground
    }
    
    func setupMediaTypePageControl() {
        addSubview(mediaTypePageControl)
        
        NSLayoutConstraint.activate([
            mediaTypePageControl.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: Const.spacingThirty),
            mediaTypePageControl.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: Const.spacingMedium)
        ])
    }
    
    func setupContainerView() {
        addSubview(containerView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: mediaTypePageControl.bottomAnchor, constant: Const.spacingExtraSmall),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            containerView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])
    }
    
    func setupMediaListCollectionView() {
        containerView.addSubview(mediaListCollectionView)
        
        NSLayoutConstraint.activate([
            mediaListCollectionView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mediaListCollectionView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            mediaListCollectionView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mediaListCollectionView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }
    
    func setupRecentSearchTableView() {
        containerView.addSubview(recentSearchTableView)
        
        NSLayoutConstraint.activate([
            recentSearchTableView.topAnchor.constraint(equalTo: containerView.topAnchor),
            recentSearchTableView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            recentSearchTableView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            recentSearchTableView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor)
        ])
    }
    
    func setupStatefulStackView() {
        containerView.addSubview(statefulStackView)
        
        NSLayoutConstraint.activate([
            statefulStackView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            statefulStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: Const.spacingOneHundred),
            statefulStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -Const.spacingOneHundred)
        ])
    }
}

// MARK: - Methods

extension MediaListSearchView {
    
    func reloadCollectionView() {
        mediaListCollectionView.reloadData()
    }
    
    func reloadTableView() {
        recentSearchTableView.reloadData()
    }
    
    func updateUI(for state: State) {
        mediaListCollectionView.isHidden = state != .loaded
        statefulStackView.update(for: state, isEmptyResults: getMediaSearchList().isEmpty)
    }
    
    func updateCollectionsVisibility(_ state: Bool) {
        recentSearchTableView.isHidden = state
        mediaListCollectionView.isHidden = !state
    }
    
    func updateStackView(with message: String?) {
        statefulStackView.updateDescriptionLabel(with: message)
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
    
    func getMediaSearchList() -> [Media] {
        delegate?.getSearchList() ?? []
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

// MARK: - StatefulStackViewDelegate Methods

extension MediaListSearchView: StatefulStackViewDelegate {
    
    func didTapRepeatButton() {
        delegate?.didTapRepeatButton()
    }
}
