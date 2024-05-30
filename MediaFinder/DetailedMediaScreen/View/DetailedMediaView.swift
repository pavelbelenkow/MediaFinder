import UIKit

// MARK: - Delegates

protocol DetailedMediaViewDelegate: AnyObject {
    func didTapMoreButton(_ model: DetailedDescription)
    func didTapArtistCollectionItem(at index: Int)
    func didTapRepeatButton()
}

final class DetailedMediaView: UIScrollView {
    
    // MARK: - Private Properties
    
    private lazy var mediaImageView: UIImageView = {
        let view = UIImageView()
        view.tintColor = .black
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var mediaInfoView: MediaInfoView = {
        let view = MediaInfoView()
        view.delegate = self
        return view
    }()
    
    private lazy var artistInfoView = ArtistInfoView()
    
    private lazy var artistCollectionView: ArtistCollectionCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = ArtistCollectionCollectionView(frame: .zero, collectionViewLayout: layout)
        view.interactionDelegate = self
        return view
    }()
    
    private lazy var detailedMediaStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            mediaInfoView, artistInfoView, artistCollectionView
        ])
        view.axis = .vertical
        view.spacing = Const.spacingMedium
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var statefulStackView: StatefulStackView = {
        let view = StatefulStackView()
        view.delegate = self
        return view
    }()
    
    // MARK: - Properties
    
    weak var interactionDelegate: DetailedMediaViewDelegate?
    
    // MARK: - Initialisers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI

private extension DetailedMediaView {
    
    func setupAppearance() {
        backgroundColor = .mediaBackground
        showsVerticalScrollIndicator = false
        delegate = self
        
        setupMediaImageView()
        setupDetailedMediaStackView()
        setupStatefulStackView()
    }
    
    func setupMediaImageView() {
        addSubview(mediaImageView)
        
        NSLayoutConstraint.activate([
            mediaImageView.topAnchor.constraint(equalTo: topAnchor),
            mediaImageView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            mediaImageView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            mediaImageView.widthAnchor.constraint(equalTo: mediaImageView.heightAnchor)
        ])
    }
    
    func setupDetailedMediaStackView() {
        addSubview(detailedMediaStackView)
        
        NSLayoutConstraint.activate([
            detailedMediaStackView.topAnchor.constraint(equalTo: mediaImageView.bottomAnchor, constant: -Const.spacingMedium),
            detailedMediaStackView.widthAnchor.constraint(equalTo: widthAnchor),
            detailedMediaStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Const.spacingMedium)
        ])
    }
    
    func setupStatefulStackView() {
        addSubview(statefulStackView)
        
        NSLayoutConstraint.activate([
            statefulStackView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            statefulStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                                       constant: Const.spacingOneHundred),
            statefulStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                        constant: -Const.spacingOneHundred)
        ])
    }
    
    func loadAndSetupImage(from urlString: String) {
        mediaImageView.addShimmerAnimation()
        
        ImageLoader.shared.loadImage(from: urlString) { [weak self] image in
            guard let self, let image else { return }
            let aspectRatio = image.size.width / image.size.height
            
            mediaImageView.image = image
            mediaImageView.widthAnchor.constraint(
                equalTo: mediaImageView.heightAnchor,
                multiplier: aspectRatio
            ).isActive = true
            
            mediaImageView.removeShimmerAnimation()
        }
    }
}

// MARK: - Methods

extension DetailedMediaView {
    
    func updateUI(for state: State) {
        statefulStackView.update(for: state, isEmptyResults: false)
        detailedMediaStackView.isHidden = !(state == .loaded)
    }
    
    func updateUI(for media: Media?) {
        guard 
            let media,
            let imageUrl = media.setImageQuality(to: Const.fiveHundredSize)
        else { return }
        
        mediaInfoView.update(for: media)
        loadAndSetupImage(from: imageUrl)
    }
    
    func updateUI(for artist: Artist?) {
        guard let artist else { return }
        artistInfoView.update(for: artist)
    }
    
    func updateUI(for collection: [Media]) {
        guard !collection.isEmpty else { return }
        artistInfoView.showMoreFromArtistLabel()
        artistCollectionView.heightAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8).isActive = true
        artistCollectionView.applySnapshot(for: collection)
    }
}

// MARK: - Delegate Methods

extension DetailedMediaView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        offsetY <= .zero ? mediaInfoView.updateImageViewFrame(for: offsetY) : nil
    }
}

// MARK: - MediaInfoViewDelegate Methods

extension DetailedMediaView: MediaInfoViewDelegate {
    
    func didTapMoreButton(_ model: DetailedDescription) {
        interactionDelegate?.didTapMoreButton(model)
    }
}

// MARK: - ArtistCollectionCollectionViewDelegate Methods

extension DetailedMediaView: ArtistCollectionCollectionViewDelegate {
    
    func didTapCollection(at index: Int) {
        interactionDelegate?.didTapArtistCollectionItem(at: index)
    }
}

// MARK: - StatefulStackViewDelegate Methods

extension DetailedMediaView: StatefulStackViewDelegate {
    
    func didTapRepeatButton() {
        interactionDelegate?.didTapRepeatButton()
    }
}
