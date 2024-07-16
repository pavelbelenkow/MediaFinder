import Combine

// MARK: - Protocols

protocol MediaPlayerViewModelProtocol: ObservableObject {
    var isPlayingSubject: CurrentValueSubject<(isPlaying: Bool, player: MediaPlayerProtocol?), Never> { get }
    var videoFinishedSubject: PassthroughSubject<Void, Never> { get }
    var cancellables: Set<AnyCancellable> { get set }
    
    func togglePlayPause()
}
