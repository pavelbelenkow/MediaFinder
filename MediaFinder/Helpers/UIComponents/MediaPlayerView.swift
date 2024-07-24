import UIKit

// MARK: - Delegates

protocol MediaPlayerViewDelegate: AnyObject {
    func didTapMediaPlayerView()
    func didTapPlayPauseButton()
    func didTapFullscreenButton()
}

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
        let playSymbol = UIImage.configuredSymbol(named: "play.fill", pointSize: 50)
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
    
    private lazy var backwardButton: UIButton = {
        let button = UIButton()
        let backwardSymbol = UIImage.configuredSymbol(named: "gobackward.10")
        button.setImage(backwardSymbol, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            self,
            action: #selector(didTapBackwardButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var forwardButton: UIButton = {
        let button = UIButton()
        let forwardSymbol = UIImage.configuredSymbol(named: "goforward.10")
        button.setImage(forwardSymbol, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(
            self,
            action: #selector(didTapForwardButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var fullscreenButton: UIButton = {
        let button = UIButton()
        let fullscreenSymbol = UIImage.configuredSymbol(named: "arrow.up.left.and.arrow.down.right", pointSize: 24)
        button.setImage(fullscreenSymbol, for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.isHidden = true
        button.addTarget(
            self,
            action: #selector(didTapFullscreenButton),
            for: .touchUpInside
        )
        return button
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer()
        gesture.addTarget(self, action: #selector(didTapMediaPlayerView))
        return gesture
    }()
    
    weak var delegate: MediaPlayerViewDelegate?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    
    func setupBackwardButton() {
        addSubview(backwardButton)
        
        NSLayoutConstraint.activate([
            backwardButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.spacingOneHundred),
            backwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor)
        ])
    }
    
    func setupForwardButton() {
        addSubview(forwardButton)
        
        NSLayoutConstraint.activate([
            forwardButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.spacingOneHundred),
            forwardButton.centerYAnchor.constraint(equalTo: playPauseButton.centerYAnchor)
        ])
    }
    
    func setupFullscreenButton() {
        addSubview(fullscreenButton)
        
        NSLayoutConstraint.activate([
            fullscreenButton.topAnchor.constraint(equalTo: topAnchor, constant: Const.spacingMedium),
            fullscreenButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.spacingMedium)
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
        let buttonSymbol = UIImage.configuredSymbol(named: isPlaying ? "pause.fill" : "play.fill", pointSize: 50)
        playPauseButton.setImage(buttonSymbol, for: .normal)
    }
}

@objc
private extension MediaPlayerView {
    
    func didTapPlayPauseButton() {
        delegate?.didTapPlayPauseButton()
    }
    
    func didTapBackwardButton() {
        // TODO: handling backward rewind
    }
    
    func didTapForwardButton() {
        // TODO: handling fast forward
    }
    
    func didTapFullscreenButton() {
        delegate?.didTapFullscreenButton()
    }
    
    func didTapMediaPlayerView() {
        delegate?.didTapMediaPlayerView()
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
            
            if let _ = previewDetails.url {
                setupOverlayView()
                setupPlayPauseButton()
                setupBackwardButton()
                setupForwardButton()
                setupFullscreenButton()
                addGestureRecognizer(tapGesture)
            }
        }
    }
}
