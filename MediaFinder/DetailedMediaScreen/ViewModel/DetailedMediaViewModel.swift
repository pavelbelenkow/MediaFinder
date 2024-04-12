import Combine

// MARK: - Protocols

protocol DetailedMediaViewModelProtocol: ObservableObject {
    var stateSubject: CurrentValueSubject<State, Never> { get }
    var errorMessageSubject: CurrentValueSubject<String?, Never> { get }
    var mediaSubject: CurrentValueSubject<Media?, Never> { get }
    var artistSubject: CurrentValueSubject<[Artist], Never> { get }
    
    var cancellables: Set<AnyCancellable> { get set }
    
    func fetchArtist()
}

final class DetailedMediaViewModel: DetailedMediaViewModelProtocol {
    
    // MARK: - Subject Properties
    
    private(set) var stateSubject = CurrentValueSubject<State, Never>(.idle)
    private(set) var errorMessageSubject = CurrentValueSubject<String?, Never>(nil)
    private(set) var mediaSubject = CurrentValueSubject<Media?, Never>(nil)
    private(set) var artistSubject = CurrentValueSubject<[Artist], Never>([])
    
    // MARK: - Private Properties
    
    private let artistLookupService: ArtistLookupServiceProtocol
    
    // MARK: - Properties
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialisers
    
    init(
        mediaModel: Media,
        artistLookupService: ArtistLookupServiceProtocol = ArtistLookupService()
    ) {
        self.mediaSubject.send(mediaModel)
        self.artistLookupService = artistLookupService
        fetchArtist()
    }
    
    // MARK: - Deinitialisers
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: - Methods

extension DetailedMediaViewModel {
    
    func fetchArtist() {
        stateSubject.send(.loading)
        
        let artistId: Int
        
        if let id = mediaSubject.value?.artistId {
            artistId = id
        } else if let id = mediaSubject.value?.collectionArtistId {
            artistId = id
        } else {
            artistSubject.send([])
            stateSubject.send(.loaded)
            return
        }
        
        artistLookupService
            .fetchArtist(by: artistId)
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
                receiveValue: { artist in
                    self.artistSubject.send(artist)
                })
            .store(in: &cancellables)
    }
}