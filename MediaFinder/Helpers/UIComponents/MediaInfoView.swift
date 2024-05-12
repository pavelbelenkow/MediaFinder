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
        view.contentMode = .scaleAspectFit
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
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
    
    private lazy var moreButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.setTitle(Const.moreButtonText, for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(moreButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var linkTextView: CustomTextView = {
        let textView = CustomTextView()
        textView.configure()
        return textView
    }()
    
    private lazy var mediaStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            kindLabel, nameLabel, artistNameLabel,
            descriptionLabel, linkTextView
        ])
        view.backgroundColor = .lightText
        view.layer.cornerRadius = Const.repeatButtonCornerRadius
        view.axis = .vertical
        view.alignment = .center
        view.spacing = Const.spacingMedium
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: Const.spacingMedium, left: Const.spacingMedium,
                                          bottom: Const.spacingMedium, right: Const.spacingMedium)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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
        spacing = Const.spacingMedium
        
        [
            activityIndicatorView, imageView, mediaStackView
        ].forEach { addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            mediaStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.spacingMedium),
            mediaStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.spacingMedium),
            
            activityIndicatorView.centerYAnchor.constraint(
                equalTo: topAnchor,
                constant: UIScreen.main.bounds.height / 4
            )
        ])
    }
    
    func loadAndSetupImage(from urlString: String) {
        activityIndicatorView.startAnimating()
        
        ImageLoader.shared.loadImage(from: urlString) { [weak self] image in
            guard let self, let image else { return }
            let aspectRatio = image.size.width / image.size.height
            
            imageView.image = image
            imageView.widthAnchor.constraint(
                equalTo: imageView.heightAnchor,
                multiplier: aspectRatio
            ).isActive = true
            
            activityIndicatorView.stopAnimating()
        }
    }
}

// MARK: - Methods

extension MediaInfoView {
    
    func update(for media: Media) {
        guard
            let imageUrl = media.setImageQuality(to: Const.fiveHundredSize),
            let kind = media.kind,
            let name = media.name,
            let artist = media.artist,
            let _ = media.trackView
        else { return }
        
        loadAndSetupImage(from: imageUrl)
        
        kindLabel.text = kind
        nameLabel.text = name
        artistNameLabel.text = Const.createdBy.appending(artist)
        
        if let description = media.description {
            descriptionLabel.text = description
        }
        
        linkTextView.attributedText = media.attributedLinkText()
    }
}
