import Combine

// MARK: - Protocols

protocol DetailedMediaViewModelProtocol: ObservableObject {
    var stateSubject: CurrentValueSubject<State, Never> { get }
    var mediaSubject: CurrentValueSubject<Media?, Never> { get }
    var artistSubject: CurrentValueSubject<[Artist], Never> { get }
    var artistCollectionSubject: CurrentValueSubject<[Media], Never> { get }
    
    var cancellables: Set<AnyCancellable> { get set }
    
    func fetchArtistAndCollection()
}

final class DetailedMediaViewModel: DetailedMediaViewModelProtocol {
    
    // MARK: - Subject Properties
    
    private(set) var stateSubject = CurrentValueSubject<State, Never>(.idle)
    private(set) var mediaSubject = CurrentValueSubject<Media?, Never>(nil)
    private(set) var artistSubject = CurrentValueSubject<[Artist], Never>([])
    private(set) var artistCollectionSubject = CurrentValueSubject<[Media], Never>([])
    
    // MARK: - Private Properties
    
    private let mediaModel: Media
    private let artistLookupService: ArtistLookupServiceProtocol
    
    // MARK: - Properties
    
    var cancellables: Set<AnyCancellable> = []
    
    // MARK: - Initialisers
    
    init(
        mediaModel: Media,
        artistLookupService: ArtistLookupServiceProtocol = ArtistLookupService()
    ) {
        self.mediaModel = mediaModel
        self.artistLookupService = artistLookupService
        fetchArtistAndCollection()
    }
    
    // MARK: - Deinitialisers
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: - Methods

extension DetailedMediaViewModel {
    
    func fetchArtistAndCollection() {
        stateSubject.send(.loading)
        
        guard let artistId = mediaModel.artistId ?? mediaModel.collectionArtistId else {
            mediaSubject.send(mediaModel)
            artistSubject.send([])
            artistCollectionSubject.send([])
            stateSubject.send(.loaded)
            return
        }
        
        let artistPublisher = artistLookupService
            .fetchArtist(by: artistId)
            .handleEvents(receiveOutput: { self.artistSubject.send($0) })
        
        let artistCollectionPublisher = artistLookupService
            .fetchArtistCollection(by: artistId)
            .handleEvents(receiveOutput: { self.artistCollectionSubject.send($0) })
        
        Publishers.Zip(artistPublisher, artistCollectionPublisher)
            .sink(receiveCompletion: { [weak self] completion in
                guard let self else { return }
                
                switch completion {
                case .failure(let failure):
                    stateSubject.send(.error(failure.localizedDescription))
                case .finished:
                    stateSubject.send(.loaded)
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
