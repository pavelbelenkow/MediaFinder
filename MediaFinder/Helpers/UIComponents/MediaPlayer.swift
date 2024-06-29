import AVFoundation
import UIKit

// MARK: - Protocols

protocol MediaPlayerProtocol {
    var isPlaying: Bool { get }
    func configure(with url: URL, isVideo: Bool)
    func play()
    func pause()
    func attachLayer(to view: UIView)
    func updateLayerFrame(to frame: CGRect)
}

final class MediaPlayer: MediaPlayerProtocol {
    
    // MARK: - Private Properties
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var isVideoContent = false
    
    // MARK: - Properties
    
    var isPlaying: Bool { player?.rate != .zero }
    
    // MARK: - Methods
    
    func configure(with url: URL, isVideo: Bool) {
        isVideoContent = isVideo
        player = AVPlayer(url: url)
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func attachLayer(to view: UIView) {
        guard let player, isVideoContent else { return }
        
        if playerLayer == nil {
            playerLayer = AVPlayerLayer(player: player)
        }
        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        
        if let playerLayer , playerLayer.superlayer == nil {
            view.layer.addSublayer(playerLayer)
        }
    }
    
    func updateLayerFrame(to frame: CGRect) {
        playerLayer?.frame = frame
    }
}
