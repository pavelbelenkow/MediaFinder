import UIKit

final class ArtistCollectionCell: UICollectionViewCell {
    
    // MARK: - Private Properties
    
    private lazy var collectionImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .black
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var collectionNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .semibold)
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var collectionGenreLabel: UILabel = {
        let label = UILabel()
        label.textColor = .systemIndigo
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 15, weight: .medium)
        return label
    }()
    
    private lazy var collectionPriceLabel: UILabel = {
        let label = UILabel()
        label.textColor = .mediaRed
        label.textAlignment = .center
        label.font = .boldSystemFont(ofSize: 13)
        return label
    }()
    
    private lazy var detailedInfoStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            collectionNameLabel, collectionGenreLabel, collectionPriceLabel
        ])
        view.axis = .vertical
        view.distribution = .fillEqually
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = UIEdgeInsets(top: Const.spacingSmall, left: Const.spacingSmall,
                                          bottom: Const.spacingSmall, right: Const.spacingSmall)
        return view
    }()
    
    private lazy var collectionStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
             collectionImageView, detailedInfoStackView
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

private extension ArtistCollectionCell {
    
    func setupAppearance() {
        backgroundColor = .lightText
        clipsToBounds = true
        layer.cornerRadius = Const.collectionCellCornerRadius
        
        contentView.addSubview(collectionStackView)
        
        NSLayoutConstraint.activate([
            collectionStackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            collectionImageView.heightAnchor.constraint(equalTo: collectionImageView.widthAnchor)
        ])
    }
    
    func cancelImageLoading() {
        if let currentUrlString {
            ImageLoader.shared.cancelLoading(for: currentUrlString)
        }
        
        currentUrlString = nil
    }
    
    func resetCellState() {
        collectionImageView.image = nil
        collectionNameLabel.text = nil
        collectionPriceLabel.text = nil
        collectionGenreLabel.text = nil
        
        removeShimmerAnimation()
    }
    
    func loadAndSetupImage(from urlString: String) {
        currentUrlString = urlString
        
        addShimmerAnimation()
        
        ImageLoader.shared.loadImage(from: urlString) { [weak self] image in
            guard let self else { return }
            removeShimmerAnimation()
            collectionImageView.image = image
        }
    }
}

// MARK: - Methods

extension ArtistCollectionCell {
    
    func configure(with item: Media) {
        
        guard
            let imageUrl = item.setImageQuality(to: Const.twoHundredAndFiftySize),
            let name = item.collection,
            let genre = item.genre,
            let price = item.collectionPrice
        else {
            return
        }
        
        loadAndSetupImage(from: imageUrl)
        
        collectionNameLabel.text = name
        collectionGenreLabel.text = genre
        collectionPriceLabel.text = NumberFormatter.currencyFormatter.string(from: price as NSNumber)
    }
}
