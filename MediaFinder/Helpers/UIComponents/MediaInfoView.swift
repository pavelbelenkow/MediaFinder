import UIKit

final class MediaInfoView: UIStackView {
    
    // MARK: - Private Properties
    
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
        label.configure(
            font: .systemFont(ofSize: 15, weight: .medium)
        )
        return label
    }()
    
    private lazy var nameLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            font: .systemFont(ofSize: 19, weight: .medium),
            backgroundColor: .white,
            cornerRadius: Const.labelCornerRadius,
            textInsets: .small,
            adjustsFontSizeToFitWidth: true
        )
        return label
    }()
    
    private lazy var artistNameLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            font: .systemFont(ofSize: 15, weight: .medium)
        )
        return label
    }()
    
    private lazy var descriptionLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            textColor: .gray,
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
        view.layoutMargins = .medium
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
        
        [imageView, mediaStackView].forEach { addArrangedSubview($0) }
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
            
            mediaStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Const.spacingMedium),
            mediaStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Const.spacingMedium)
        ])
    }
    
    func setupMoreButton() {
        mediaStackView.addSubview(moreButton)
        
        NSLayoutConstraint.activate([
            moreButton.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            moreButton.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor)
        ])
    }
    
    func loadAndSetupImage(from urlString: String) {
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
        }
    }
    
    @objc func moreButtonTapped() {
        descriptionLabel.animateLabelExpansion(with: moreButton)
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
            description.count > 140 ? setupMoreButton() : nil
        }
        
        linkTextView.attributedText = media.attributedLinkText()
    }
    
    func updateImageViewFrame(for point: CGFloat) {
        imageView.frame.origin.y = point
    }
}
