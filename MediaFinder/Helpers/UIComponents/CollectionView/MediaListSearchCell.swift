import UIKit

final class MediaListSearchCell: UICollectionViewCell {
    
    // MARK: - Private Properties
    
    private lazy var mediaImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        return view
    }()
    
    private lazy var mediaKindLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private lazy var mediaNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 17)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var mediaDurationLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        return label
    }()
    
    private lazy var mediaPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .mediaRed
        label.font = .boldSystemFont(ofSize: 15)
        return label
    }()
    
    private lazy var mediaDetailedStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [mediaDurationLabel, mediaPriceLabel])
        view.axis = .horizontal
        view.distribution = .equalSpacing
        return view
    }()
    
    private lazy var mediaStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [mediaImageView, mediaKindLabel, mediaNameLabel, mediaDetailedStackView])
        view.axis = .vertical
        view.distribution = .equalSpacing
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: Const.spacingSmall, left: Const.spacingSmall, 
                                          bottom: Const.spacingSmall, right: Const.spacingSmall)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
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
        mediaImageView.image = nil
    }
}

// MARK: - Setup UI

private extension MediaListSearchCell {
    
    func setupAppearance() {
        backgroundColor = .white
        layer.cornerRadius = Const.collectionCellCornerRadius
        
        contentView.addSubview(mediaStackView)
        
        NSLayoutConstraint.activate([
            mediaStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            mediaStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            mediaStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            mediaStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            mediaImageView.heightAnchor.constraint(equalToConstant: Const.mediaImageViewHeight)
        ])
    }
}

// MARK: - Methods

extension MediaListSearchCell {
    
    func configure(with media: Media) {
        
        guard
            let image = media.artwork100,
            let kind = media.kind,
            let name = media.name,
            let duration = media.duration,
            let price = media.price
        else {
            return
        }
        
        ImageLoader.shared.loadImage(from: image) { [weak self] image in
            self?.mediaImageView.image = image
        }
        
        mediaKindLabel.text = kind
        mediaNameLabel.text = name
        mediaDurationLabel.text = duration.millisecondsToReadableString()
        mediaPriceLabel.text = NumberFormatter.currencyFormatter.string(from: price as NSNumber)
    }
}
