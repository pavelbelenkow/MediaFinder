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
    private(set) var searchTermSubject = CurrentValueSubject<String, Never>("")
    private(set) var mediaTypeSubject = CurrentValueSubject<EntityType, Never>(.all)
    private(set) var limitSubject = CurrentValueSubject<Int, Never>(30)
    
    // MARK: - Private Properties
    
    private let mediaListSearchService: MediaListSearchServiceProtocol
    private var currentPage: Int
    
    // MARK: - Properties
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialisers
    
    init(service: MediaListSearchServiceProtocol = MediaListSearchService()) {
        self.mediaListSearchService = service
        self.currentPage = 0
    }
    
    // MARK: - Deinitialisers
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: - Methods

extension MediaListSearchViewModel {
    
    func getSearchList() {
        currentPage += 1
        stateSubject.send(.loading)
        
        mediaListSearchService
            .fetchMediaList(
                for: searchTermSubject.value,
                type: mediaTypeSubject.value,
                limit: limitSubject.value,
                page: 0
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
    
    func setSearchTerm(for term: String) {
        searchTermSubject.send(term)
        getSearchList()
    }
    
    func setMediaType(_ type: EntityType) {
        mediaTypeSubject.send(type)
        getSearchList()
    }
}
