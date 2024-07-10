import AVFoundation
import UIKit

// MARK: - Protocols

protocol MediaPlayerProtocol {
    var isPlaying: Bool { get }
    var currentItem: AVPlayerItem? { get }
    func configure(with url: URL, isVideo: Bool)
    func play()
    func pause()
    func attachLayer(to view: UIView)
    func updateLayerFrame(to frame: CGRect)
    func addObserver()
}

final class MediaPlayer: MediaPlayerProtocol {
    
    // MARK: - Private Properties
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItemObserver: NSKeyValueObservation?
    private var isVideoContent = false
    
    // MARK: - Properties
    
    var isPlaying: Bool { player?.rate != .zero }
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
    
    func addObserver() {
        guard let currentItem else { return }
        
        playerItemObserver?.invalidate()
        
        playerItemObserver = currentItem.observe(
            \.status,
             options: [.new, .initial]
        ) { [weak self] item, _ in
            guard let self else { return }
            
            if item.status == .readyToPlay {
                NotificationCenter.default.addObserver(
                    self,
                    selector: #selector(playerDidFinishPlaying),
                    name: .AVPlayerItemDidPlayToEndTime,
                    object: currentItem
                )
            }
        }
    }
    @objc
    private func playerDidFinishPlaying() {
    }
}
