import UIKit

final class MediaPlayerView: UIView {
    
    // MARK: - Private Properties
    
    private let imageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .black
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black.withAlphaComponent(0.2)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var playPauseButton: UIButton = {
        let button = UIButton()
        let playSymbol = UIImage.configuredSymbol(named: "play.circle")
        button.setImage(playSymbol, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            self,
            action: #selector(didTapPlayPauseButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private let mediaPlayer: MediaPlayerProtocol
    
    // MARK: - Initializers
    
    init(mediaPlayer: MediaPlayerProtocol = MediaPlayer()) {
        self.mediaPlayer = mediaPlayer
        super.init(frame: .zero)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Overridden Methods
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mediaPlayer.updateLayerFrame(to: imageView.bounds)
    }
}

// MARK: - Setup UI

private extension MediaPlayerView {
    
    func setupAppearance() {
        translatesAutoresizingMaskIntoConstraints = false
        setupImageView()
    }
    
    func setupImageView() {
        addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupOverlayView() {
        addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func setupPlayPauseButton() {
        addSubview(playPauseButton)
        
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: - Private Methods

private extension MediaPlayerView {
    
    func loadAndSetupImage(from urlString: String, completion: @escaping (UIImage) -> ()) {
        imageView.addShimmerAnimation()
        
        ImageLoader.shared.loadImage(from: urlString) { [weak self] image in
            guard let self, let image else { return }
            let aspectRatio = image.size.width / image.size.height
            
            imageView.image = image
            imageView.widthAnchor.constraint(
                equalTo: imageView.heightAnchor,
                multiplier: aspectRatio
            ).isActive = true
            
            imageView.removeShimmerAnimation()
            
            completion(image)
        }
    }
    
    func updatePlayPauseButton(isPlaying: Bool) {
        let buttonSymbol = UIImage.configuredSymbol(named: isPlaying ? "pause.circle" : "play.circle")
        playPauseButton.setImage(buttonSymbol, for: .normal)
    }
}

@objc
private extension MediaPlayerView {
    
    func didTapPlayPauseButton() {
        if mediaPlayer.isPlaying {
            mediaPlayer.pause()
            updatePlayPauseButton(isPlaying: false)
        } else {
            mediaPlayer.play()
            mediaPlayer.attachLayer(to: imageView)
            updatePlayPauseButton(isPlaying: true)
        }
    }
    }
}

// MARK: - Methods

extension MediaPlayerView {
    
    func update(
        with imageUrl: String,
        previewDetails: (url: URL?, isVideo: Bool),
        _ completion: @escaping (UIImage) -> ()
    ) {
        loadAndSetupImage(from: imageUrl) { [weak self] image in
            guard let self else { return }
            completion(image)
            
            if let previewUrl = previewDetails.url {
                setupOverlayView()
                setupPlayPauseButton()
                mediaPlayer.configure(with: previewUrl, isVideo: previewDetails.isVideo)
            }
        }
    }
}
