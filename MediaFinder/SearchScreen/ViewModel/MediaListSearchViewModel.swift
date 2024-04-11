import Combine

enum State {
    case idle
    case loading
    case loaded
    case error
}

// MARK: - Protocols

protocol MediaListSearchViewModelProtocol: ObservableObject {
    var stateSubject: CurrentValueSubject<State, Never> { get }
    var errorMessageSubject: CurrentValueSubject<String?, Never> { get }
    var searchListSubject: CurrentValueSubject<[Media], Never> { get }
    var recentSearchesSubject: CurrentValueSubject<[String], Never> { get }
    var searchBarPlaceholderSubject: CurrentValueSubject<String, Never> { get }
    var searchBarTextSubject: CurrentValueSubject<String?, Never> { get }
    var limitSubject: CurrentValueSubject<Int, Never> { get }
    
    var cancellables: Set<AnyCancellable> { get set }
    
    func fetchSearchList()
    func fetchSearchListForMediaType(by index: Int)
    func setSearchTerm(for text: String)
    func setResultsLimit(for limit: Int)
    func filterSuggestions(for text: String?)
    func didSelectRecentSearch(at index: Int)
}

final class MediaListSearchViewModel: MediaListSearchViewModelProtocol {
    
    // MARK: - Subject Properties
    
    private(set) var stateSubject = CurrentValueSubject<State, Never>(.idle)
    private(set) var errorMessageSubject = CurrentValueSubject<String?, Never>(nil)
    private(set) var searchListSubject = CurrentValueSubject<[Media], Never>([])
    private(set) var recentSearchesSubject = CurrentValueSubject<[String], Never>([])
    private(set) var searchBarPlaceholderSubject = CurrentValueSubject<String, Never>(Const.songsAndMoviesPlaceholder)
    private(set) var searchBarTextSubject = CurrentValueSubject<String?, Never>(nil)
    private(set) var limitSubject = CurrentValueSubject<Int, Never>(Const.limitThirty)
    
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
        currentPage += 1
        stateSubject.send(.loading)
        
        mediaListSearchService
            .fetchMediaList(
                for: searchTerm,
                type: entityType,
                limit: limitSubject.value,
                page: .zero
            )
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    
                    switch completion {
                    case .failure(let failure):
                        stateSubject.send(.error)
                        errorMessageSubject.send(failure.localizedDescription)
                    case .finished:
                        stateSubject.send(.loaded)
                    }
                },
                receiveValue: { mediaList in
                    self.searchListSubject.send(mediaList)
                })
            .store(in: &cancellables)
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
        
        fetchSearchList()
    }
    
    func setSearchTerm(for text: String) {
        guard !text.isEmpty else { return }
        
        searchTerm = text
        searchHistoryStorage.addSearchTerm(text)
        recentSearchesSubject.send(searchHistoryStorage.recentSearches)
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
}
