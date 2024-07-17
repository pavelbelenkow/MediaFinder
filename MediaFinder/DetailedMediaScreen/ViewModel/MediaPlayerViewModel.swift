import Combine

// MARK: - Protocols

protocol MediaPlayerViewModelProtocol: ObservableObject {
    var isPlayingSubject: CurrentValueSubject<(isPlaying: Bool, player: MediaPlayerProtocol?), Never> { get }
    var videoFinishedSubject: PassthroughSubject<Void, Never> { get }
    var cancellables: Set<AnyCancellable> { get set }
    
    func togglePlayPause()
}

final class MediaPlayerViewModel: MediaPlayerViewModelProtocol {
    
    // MARK: - Subject Properties
    
    private(set) var isPlayingSubject = CurrentValueSubject<(isPlaying: Bool, player: MediaPlayerProtocol?), Never>((false, nil))
    private(set) var videoFinishedSubject = PassthroughSubject<Void, Never>()
    
    // MARK: - Private Properties
    
    private let model: Media
    private let mediaPlayer: MediaPlayerProtocol
    
    // MARK: - Properties
    
    var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initializers
    
    init(
        model: Media,
        mediaPlayer: MediaPlayerProtocol = MediaPlayer()
    ) {
        self.model = model
        self.mediaPlayer = mediaPlayer
    }
    
    // MARK: - Deinitializers
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: - Methods

extension MediaPlayerViewModel {
    
    func togglePlayPause() {
        if isPlayingSubject.value.isPlaying {
            mediaPlayer.pause()
            isPlayingSubject.send((false, mediaPlayer))
        } else {
            mediaPlayer.play()
            mediaPlayer.addObserver()
            isPlayingSubject.send((true, mediaPlayer))
        }
    }
}
