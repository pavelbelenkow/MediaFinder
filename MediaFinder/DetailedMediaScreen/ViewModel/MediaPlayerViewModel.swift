import Foundation
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
        configure()
    }
    
    // MARK: - Deinitializers
    
    deinit {
        cancellables.forEach { $0.cancel() }
    }
}

// MARK: - Private Methods

private extension MediaPlayerViewModel {
    
    func configure() {
        let preview = model.previewDetails()
        if let url = preview.url {
            mediaPlayer.configure(with: url, isVideo: preview.isVideo)
            setupBindings()
        }
    }
    
    func setupBindings() {
        NotificationCenter
            .default
            .publisher(for: .AVPlayerItemDidPlayToEndTime, object: mediaPlayer.currentItem)
            .sink { [weak self] _ in
                self?.videoFinishedSubject.send()
            }
            .store(in: &cancellables)
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
