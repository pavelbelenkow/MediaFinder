import UIKit

// MARK: - Delegates

protocol DetailedMediaViewDelegate: AnyObject {
    func didTapArtistCollectionItem(at index: Int)
    func didTapRepeatButton()
}

final class DetailedMediaView: UIScrollView {
    
    // MARK: - Private Properties
    
    private lazy var mediaInfoView = MediaInfoView()
    private lazy var artistInfoView = ArtistInfoView()
    
    private lazy var moreFromArtistLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.numberOfLines = .zero
        return label
    }()
    
    private lazy var artistCollectionView: ArtistCollectionCollectionView = {
        let layout = UICollectionViewFlowLayout()
        let view = ArtistCollectionCollectionView(frame: .zero, collectionViewLayout: layout)
        view.interactionDelegate = self
        return view
    }()
    
    private lazy var detailedMediaStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [mediaInfoView, artistInfoView, moreFromArtistLabel])
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
        
        setupDetailedMediaStackView()
        setupArtistCollectionView()
        setupStatefulStackView()
    }
    
    func setupDetailedMediaStackView() {
        addSubview(detailedMediaStackView)
        
        NSLayoutConstraint.activate([
            detailedMediaStackView.topAnchor.constraint(equalTo: topAnchor,
                                                        constant: Const.spacingMedium),
            detailedMediaStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor,
                                                            constant: Const.spacingMedium),
            detailedMediaStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor,
                                                             constant: -Const.spacingMedium)
        ])
    }
    
    func setupArtistCollectionView() {
        addSubview(artistCollectionView)
        
        NSLayoutConstraint.activate([
            artistCollectionView.heightAnchor.constraint(greaterThanOrEqualTo: heightAnchor, multiplier: 0.4),
            artistCollectionView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Const.spacingMedium),
            artistCollectionView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            artistCollectionView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            artistCollectionView.topAnchor.constraint(equalTo: detailedMediaStackView.bottomAnchor, constant: Const.spacingMedium)
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
}

// MARK: - Methods

extension DetailedMediaView {
    
    func updateUI(for state: State) {
        statefulStackView.update(for: state, isEmptyResults: false)
        [
            detailedMediaStackView, moreFromArtistLabel, artistCollectionView
        ].forEach { $0.isHidden = !(state == .loaded) }
    }
    
    func updateUI(for media: Media?) {
        guard let media else { return }
        mediaInfoView.update(for: media)
    }
    
    func updateUI(for artist: Artist?) {
        guard let artist else { return }
        artistInfoView.update(for: artist)
        moreFromArtistLabel.text = artist.moreFromArtistPlaceHolder()
    }
    
    func updateUI(for collection: [Media]) {
        moreFromArtistLabel.isHidden = collection.isEmpty
        artistCollectionView.applySnapshot(for: collection)
        
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
