import Foundation
import Combine

// MARK: - Protocols

protocol MediaPlayerViewModelProtocol: ObservableObject {
    var stateSubject: CurrentValueSubject<(state: MediaPlayerState, controlsVisible: Bool), Never> { get }
    var cancellables: Set<AnyCancellable> { get set }
    
    func togglePlayPause()
}

final class MediaPlayerViewModel: MediaPlayerViewModelProtocol {
    
    // MARK: - Subject Properties
    
    private(set) var stateSubject = CurrentValueSubject<(state: MediaPlayerState, controlsVisible: Bool), Never>((.idle, true))
    
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
                self?.stateSubject.send((.finished, true))
            }
            .store(in: &cancellables)
    }
}

// MARK: - Methods

extension MediaPlayerViewModel {
    
    func togglePlayPause() {
        switch stateSubject.value.state {
        case .idle, .finished:
            mediaPlayer.backToBeginning()
            mediaPlayer.play()
            stateSubject.send((.playing(mediaPlayer), true))
        case .playing:
            mediaPlayer.pause()
            stateSubject.send((.paused(mediaPlayer), true))
        case .paused:
            mediaPlayer.play()
            stateSubject.send((.playing(mediaPlayer), true))
        }
    }
}
