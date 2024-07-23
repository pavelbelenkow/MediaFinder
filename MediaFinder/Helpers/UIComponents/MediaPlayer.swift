import AVFoundation
import UIKit

// MARK: - Protocols

protocol MediaPlayerProtocol {
    var currentItem: AVPlayerItem? { get }
    func configure(with url: URL, isVideo: Bool)
    func play()
    func pause()
    func backToBeginning()
    func attachLayer(to view: UIView)
    func detachLayer()
}

final class MediaPlayer: MediaPlayerProtocol {
    
    // MARK: - Private Properties
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var isVideoContent = false
    
    // MARK: - Properties
    
    var currentItem: AVPlayerItem? { player?.currentItem }
    
    // MARK: - Methods
    
    func configure(with url: URL, isVideo: Bool) {
        let playerItem = AVPlayerItem(url: url)
        player = AVPlayer(playerItem: playerItem)
        isVideoContent = isVideo
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func backToBeginning() {
        player?.seek(to: .zero)
    }
    
    func attachLayer(to view: UIView) {
        guard let player, isVideoContent else { return }
        
        if playerLayer == nil {
            playerLayer = AVPlayerLayer(player: player)
        }
        playerLayer?.frame = view.bounds
        playerLayer?.videoGravity = .resizeAspectFill
        
        if let playerLayer, playerLayer.superlayer == nil {
            view.layer.addSublayer(playerLayer)
        }
    }
    
    func detachLayer() {
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
    }
    
        
        }
    }
    
    }
}
