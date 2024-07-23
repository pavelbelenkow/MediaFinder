import Foundation

enum MediaPlayerState {
    case idle
    case playing(MediaPlayerProtocol)
    case paused
    case finished(MediaPlayerProtocol)
}
