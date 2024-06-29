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
}

// MARK: - Setup UI

private extension MediaPlayerView {
    
    func setupAppearance() {
        translatesAutoresizingMaskIntoConstraints = false
        
        setupImageView()
        setupOverlayView()
        setupPlayPauseButton()
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
    
    @objc
    func didTapPlayPauseButton() {
        // TODO: add handle of play and pause media preview
    }
}

// MARK: - Methods

extension MediaPlayerView {
    
    func update(
        with imageUrl: String,
        previewDetails: (url: URL?, isVideo: Bool),
        _ completion: @escaping (UIImage) -> ()
    ) {
        loadAndSetupImage(from: imageUrl, completion: completion)
    }
}
