import UIKit

final class MediaListSearchCell: UICollectionViewCell {
    
    // MARK: - Private Properties
    
    private lazy var mediaImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .black
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var mediaNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private lazy var mediaKindLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    private lazy var mediaDurationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    private lazy var mediaPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .mediaRed
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    
    private lazy var mediaHorizontalStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [mediaDurationLabel, mediaPriceLabel])
        view.axis = .horizontal
        view.spacing = Const.spacingSmall
        return view
    }()
    
    private lazy var mediaDetailedStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            mediaNameLabel, mediaKindLabel, mediaHorizontalStackView
        ])
        view.axis = .vertical
        view.alignment = .leading
        view.spacing = Const.spacingSmall
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .small
        return view
    }()
    
    private lazy var mediaStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            mediaImageView, mediaDetailedStackView
        ])
        view.axis = .vertical
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var currentUrlString: String?
    
    // MARK: - Initialisers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cancelImageLoading()
        resetCellState()
    }
}

// MARK: - Setup UI

private extension MediaListSearchCell {
    
    func setupAppearance() {
        backgroundColor = .lightText
        layer.cornerRadius = Const.collectionCellCornerRadius
        layer.masksToBounds = true
        
        contentView.addSubview(mediaStackView)
        
        NSLayoutConstraint.activate([
            mediaStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mediaStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            mediaDetailedStackView.heightAnchor.constraint(equalToConstant: Const.spacingOneHundred)
        ])
    }
    
    func cancelImageLoading() {
        if let currentUrlString {
            ImageLoader.shared.cancelLoading(for: currentUrlString)
        }
        
        currentUrlString = nil
    }
    
    func resetCellState() {
        mediaImageView.image = nil
        mediaKindLabel.text = nil
        mediaNameLabel.text = nil
        mediaDurationLabel.text = nil
        mediaPriceLabel.text = nil
        
        removeShimmerAnimation()
    }
    
    func loadAndSetupImage(from urlString: String) {
        currentUrlString = urlString
        
        addShimmerAnimation(borderWidth: 1)
        isUserInteractionEnabled = false
        
        ImageLoader.shared.loadImage(from: urlString) { [weak self] image in
            guard let self else { return }
            removeShimmerAnimation()
            mediaImageView.image = image
            isUserInteractionEnabled = true
        }
    }
}

// MARK: - Methods

extension MediaListSearchCell {
    
    func configure(with media: Media) {
        
        guard
            let imageUrl = media.setImageQuality(to: Const.twoHundredAndFiftySize),
            let kind = media.kind,
            let name = media.name,
            let duration = media.duration,
            let price = media.price
        else {
            return
        }
        
        loadAndSetupImage(from: imageUrl)
        
        mediaNameLabel.text = name
        mediaKindLabel.text = kind
        mediaDurationLabel.text = duration.millisecondsToReadableString()
        mediaPriceLabel.text = NumberFormatter.currencyFormatter.string(from: price as NSNumber)
    }
}
