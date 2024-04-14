import Combine

enum State: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}

// MARK: - Protocols

protocol MediaListSearchViewModelProtocol: ObservableObject {
    var stateSubject: CurrentValueSubject<State, Never> { get }
    var searchListSubject: CurrentValueSubject<[Media], Never> { get }
    var recentSearchesSubject: CurrentValueSubject<[String], Never> { get }
    var searchBarPlaceholderSubject: CurrentValueSubject<String, Never> { get }
    var searchBarTextSubject: CurrentValueSubject<String?, Never> { get }
    var limitSubject: CurrentValueSubject<Int, Never> { get }
    var selectedMediaSubject: CurrentValueSubject<Media?, Never> { get }
    
    var cancellables: Set<AnyCancellable> { get set }
    
    func fetchSearchList()
    func loadNextPageIfNeeded()
    func fetchSearchListForMediaType(by index: Int)
    func setSearchTerm(for text: String)
    func setResultsLimit(for limit: Int)
    func filterSuggestions(for text: String?)
    func didSelectRecentSearch(at index: Int)
    func didSelectMedia(at index: Int)
}

final class MediaListSearchViewModel: MediaListSearchViewModelProtocol {
    
    // MARK: - Subject Properties
    
    private(set) var stateSubject = CurrentValueSubject<State, Never>(.idle)
    private(set) var searchListSubject = CurrentValueSubject<[Media], Never>([])
    private(set) var recentSearchesSubject = CurrentValueSubject<[String], Never>([])
    private(set) var searchBarPlaceholderSubject = CurrentValueSubject<String, Never>(Const.songsAndMoviesPlaceholder)
    private(set) var searchBarTextSubject = CurrentValueSubject<String?, Never>(nil)
    private(set) var limitSubject = CurrentValueSubject<Int, Never>(Const.limitThirty)
    private(set) var selectedMediaSubject = CurrentValueSubject<Media?, Never>(nil)
    
    // MARK: - Private Properties
    
    private let mediaListSearchService: MediaListSearchServiceProtocol
    private let searchHistoryStorage: SearchHistoryStorageProtocol
    private var currentPage: Int
    private var searchTerm = ""
    private var entityType: EntityType = .all
    
    // MARK: - Properties
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialisers
    
    init(
        service: MediaListSearchServiceProtocol = MediaListSearchService(),
        storage: SearchHistoryStorageProtocol = SearchHistoryStorage.shared
    ) {
        self.mediaListSearchService = service
        self.searchHistoryStorage = storage
        self.recentSearchesSubject.send(searchHistoryStorage.recentSearches)
        self.currentPage = .zero
    }
    
    // MARK: - Deinitialisers
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: - Methods

extension MediaListSearchViewModel {
    
    func fetchSearchList() {
        
        guard !(stateSubject.value == .loading) else { return }
        
        stateSubject.send(.loading)
        
        mediaListSearchService
            .fetchMediaList(
                for: searchTerm,
                type: entityType,
                limit: limitSubject.value,
                page: currentPage
            )
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    
                    if case .failure(let failure) = completion {
                        stateSubject.send(.error(failure.localizedDescription))
                    }
                },
                receiveValue: { [weak self] mediaList in
                    guard let self else { return }
                    
                    if currentPage == .zero {
                        searchListSubject.send(mediaList)
                    } else {
                        let currentMediaList = searchListSubject.value
                        let updatedMediaList = currentMediaList + mediaList
                        searchListSubject.send(updatedMediaList)
                    }
                    
                    stateSubject.send(.loaded)
                })
            .store(in: &cancellables)
    }
    
    func loadNextPageIfNeeded() {
        currentPage += 1
        fetchSearchList()
    }
    
    func fetchSearchListForMediaType(by index: Int) {
        
        switch index {
        case 0:
            searchBarPlaceholderSubject.send(Const.songsAndMoviesPlaceholder)
            entityType = .all
        case 1:
            searchBarPlaceholderSubject.send(Const.moviesPlaceholder)
            entityType = .movie
        case 2:
            searchBarPlaceholderSubject.send(Const.songsPlaceholder)
            entityType = .song
        default:
            break
        }
        
        guard !searchTerm.isEmpty else { return }
        currentPage = .zero
        fetchSearchList()
    }
    
    func setSearchTerm(for text: String) {
        guard !text.isEmpty, text != searchTerm else { return }
        
        searchTerm = text
        searchHistoryStorage.addSearchTerm(text)
        recentSearchesSubject.send(searchHistoryStorage.recentSearches)
        currentPage = .zero
        fetchSearchList()
    }
    
    func setResultsLimit(for limit: Int) {
        limitSubject.send(limit)
    }
    
    func filterSuggestions(for searchText: String?) {
        guard
            let searchText,
            !searchText.isEmpty
        else {
            recentSearchesSubject.send(searchHistoryStorage.recentSearches)
            return
        }
        
        let filteredSuggestions = recentSearchesSubject.value.filter {
            $0.localizedCaseInsensitiveContains(searchText)
        }
        
        recentSearchesSubject.send(filteredSuggestions)
    }
    
    func didSelectRecentSearch(at index: Int) {
        let selectedRecentSearch = recentSearchesSubject.value[index]
        searchBarTextSubject.send(selectedRecentSearch)
    }
    
    func didSelectMedia(at index: Int) {
        let selectedMediaItem = searchListSubject.value[index]
        selectedMediaSubject.send(selectedMediaItem)
    }
}
