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
