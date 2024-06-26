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
}

// MARK: - Methods

extension MediaPlayerView {
    
    func update(
        with imageUrl: String,
        preview: String?,
        _ completion: @escaping (UIImage) -> ()
    ) {
        loadAndSetupImage(from: imageUrl, completion: completion)
    }
}