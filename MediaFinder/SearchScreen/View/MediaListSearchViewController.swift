import UIKit

final class MediaListSearchViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var mediaListSearchView: MediaListSearchView = {
        let view = MediaListSearchView()
        view.delegate = self
        return view
    }()
    
    private let viewModel: any MediaListSearchViewModelProtocol
    
    // MARK: - Initialisers
    
    init(viewModel: any MediaListSearchViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        view = mediaListSearchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        bindViewModel()
    }
}

// MARK: - Setup Navigation Bar

private extension MediaListSearchViewController {
    
    func setupNavigationBar() {
        let navigationBar = navigationController?.navigationBar
        navigationBar?.standardAppearance.shadowColor = .clear
        navigationBar?.standardAppearance.backgroundColor = .mediaBackground
        
        setupTitle(for: navigationBar)
        setupRightBarButtonItem()
        setupSearchController()
    }
    
    func setupTitle(for navigationBar: UINavigationBar?) {
        title = Const.navigationBarTitle
        navigationBar?.tintColor = .white
        navigationBar?.prefersLargeTitles = true
        navigationBar?.standardAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navigationBar?.standardAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
    }
    
    func setupRightBarButtonItem() {
        let limits = [Const.limitTen, Const.limitThirty, Const.limitFifty]
        let menu = UIMenu(
            children: limits.map {
                UICommand(
                    title: String($0),
                    action: #selector(limitButtonTapped),
                    propertyList: $0,
                    state: $0 == Const.limitThirty ? .on : .off
                )
            }
        )
        
        let rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: Const.limitIcon),
            menu: menu
        )
        
        navigationItem.setRightBarButton(rightBarButtonItem, animated: true)
    }
    
    func setupSearchController() {
        searchController.searchBar.placeholder = Const.songsAndMoviesPlaceholder
        searchController.searchBar.tintColor = .black
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
    }
}

// MARK: - Private Methods

private extension MediaListSearchViewController {
    
    func bindViewModel() {
        viewModel.stateSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                let isEmpty = self?.viewModel.searchListSubject.value.isEmpty ?? true
                self?.mediaListSearchView.updateUI(for: state, isEmptyResults: isEmpty)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.searchListSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] mediaList, mediaType in
                self?.mediaListSearchView.reloadCollectionView(with: mediaList, and: mediaType)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.recentSearchesSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] recentSearches in
                self?.mediaListSearchView.reloadTableView()
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.searchBarPlaceholderSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] placeholder in
                self?.searchController.searchBar.placeholder = placeholder
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.searchBarTextSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.updateSearchBarTerm(with: text)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.limitSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] limit in
                self?.updateMenuState(limit)
            }
            .store(in: &viewModel.cancellables)
        
        viewModel.selectedMediaSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectedMedia in
                guard let self, let selectedMedia else { return }
                self.presentDetailedMediaViewController(with: selectedMedia)
            }
            .store(in: &viewModel.cancellables)
    }
    
    func updateSearchBarTerm(with text: String?) {
        let searchBar = searchController.searchBar
        searchBar.text = text
        searchBar.resignFirstResponder()
        searchBarSearchButtonClicked(searchBar)
    }
    
    func updateMenuState(_ selectedLimit: Int) {
        guard
            let rightBarButtonItem = navigationItem.rightBarButtonItem,
            let menu = rightBarButtonItem.menu
        else { return }
        
        for case let menuItem in menu.children {
            if let command = menuItem as? UICommand {
                command.state = (command.propertyList as? Int == selectedLimit) ? .on : .off
            }
        }
    }
    
    func presentDetailedMediaViewController(with selectedMedia: Media) {
        let viewModel = DetailedMediaViewModel(mediaModel: selectedMedia)
        let viewController = DetailedMediaViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true)
    }
    
    @objc func limitButtonTapped(_ sender: UICommand) {
        if let limit = sender.propertyList as? Int {
            viewModel.setResultsLimit(for: limit)
        }
    }
}

// MARK: - UISearchBarDelegate Methods

extension MediaListSearchViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard
            let text = searchBar.text,
            !text.isEmpty
        else {
            return
        }
        
        mediaListSearchView.updateCollectionsVisibility(true)
        viewModel.setSearchTerm(for: text)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        mediaListSearchView.updateCollectionsVisibility(false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        mediaListSearchView.updateCollectionsVisibility(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filterSuggestions(for: searchText)
    }
    
    func searchBar(
        _ searchBar: UISearchBar,
        shouldChangeTextIn range: NSRange,
        replacementText text: String
    ) -> Bool {
        viewModel.filterSuggestions(for: text)
        return true
    }
}

// MARK: - MediaListSearchViewDelegate Methods

extension MediaListSearchViewController: MediaListSearchViewDelegate {
    
    func didSelectMediaType(for index: Int) {
        viewModel.fetchSearchListForMediaType(by: index)
    }
    
    func didScrollToBottomCollectionView() {
        viewModel.loadNextPageIfNeeded()
    }
    
    func didTapInnerContentCollectionView(at index: Int) {
        viewModel.didSelectMedia(at: index)
    }
    
    func didTapFooterRepeatButton() {
        viewModel.fetchSearchList()
    }
    
    func getRecentSearches() -> [String] {
        viewModel.recentSearchesSubject.value
    }
    
    func didTapRecentTerm(at index: Int) {
        viewModel.didSelectRecentSearch(at: index)
    }
}
