import UIKit

final class MediaInfoView: UIStackView {
    
    // MARK: - Private Properties
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .medium
        view.color = .white
        return view
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .black
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = Const.imageViewCornerRadius
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var kindLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure()
        return label
    }()
    
    private lazy var nameLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(textColor: .white, font: .boldSystemFont(ofSize: 24))
        return label
    }()
    
    private lazy var artistNameLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(font: .systemFont(ofSize: 18, weight: .medium))
        return label
    }()
    
    private lazy var descriptionLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            textColor: .white,
            font: .italicSystemFont(ofSize: 15),
            alignment: .justified,
            numberOfLines: 3
        )
        return label
    }()
    
    private lazy var linkTextView: CustomTextView = {
        let textView = CustomTextView()
        textView.configure()
        textView.backgroundColor = .lightText
        textView.layer.cornerRadius = Const.linkCornerRadius
        return textView
    }()
    
    // MARK: - Initialisers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI

private extension MediaInfoView {
    
    func setupAppearance() {
        axis = .vertical
        alignment = .center
        spacing = Const.spacingSmall
        [
            imageView, kindLabel, nameLabel,
            artistNameLabel, descriptionLabel, linkTextView
        ].forEach { addArrangedSubview($0) }
    }
}

// MARK: - Methods

extension MediaInfoView {
    
    func update(for media: Media) {
        guard
            let image = media.setImageQuality(to: Const.fiveHundredSize),
            let kind = media.kind,
            let name = media.name,
            let artist = media.artist,
            let _ = media.trackView
        else { return }
        
        activityIndicatorView.startAnimating()
        
        ImageLoader.shared.loadImage(from: image) { [weak self] image in
            self?.activityIndicatorView.stopAnimating()
            self?.imageView.image = image
        }
        
        kindLabel.text = kind
        nameLabel.text = name
        artistNameLabel.text = Const.createdBy.appending(artist)
        
        if let description = media.description {
            descriptionLabel.text = description
        }
        
        linkTextView.attributedText = media.attributedLinkText()
    }
}
