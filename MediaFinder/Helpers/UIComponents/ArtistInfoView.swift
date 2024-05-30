import UIKit

final class ArtistInfoView: UIStackView {
    
    // MARK: - Private Properties
    
    private lazy var titleLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            font: .systemFont(ofSize: 17, weight: .medium),
            alignment: .left
        )
        return label
    }()
    
    private lazy var nameLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(alignment: .left)
        return label
    }()
    
    private lazy var genreLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            textColor: .systemIndigo,
            font: .systemFont(ofSize: 13, weight: .medium),
            alignment: .left
        )
        return label
    }()
    
    private lazy var linkTextView: CustomTextView = {
        let textView = CustomTextView()
        textView.configure()
        return textView
    }()
    
    private lazy var artistInfoStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            nameLabel, genreLabel, linkTextView
        ])
        view.backgroundColor = .white
        view.axis = .vertical
        view.spacing = Const.spacingSmall
        view.layer.cornerRadius = 10
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .medium
        return view
    }()
    
    private lazy var moreFromArtistLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            font: .systemFont(ofSize: 17, weight: .medium),
            alignment: .left
        )
        label.isHidden = true
        return label
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

private extension ArtistInfoView {
    
    func setupAppearance() {
        axis = .vertical
        spacing = Const.spacingMedium
        isHidden = true
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .medium
        
        [
            titleLabel, artistInfoStackView, moreFromArtistLabel
        ].forEach { addArrangedSubview($0) }
    }
}

// MARK: - Methods

extension ArtistInfoView {
    
    func update(for artist: Artist) {
        isHidden = false
        
        titleLabel.text = Const.aboutArtist.appending(artist.kind)
        nameLabel.text = artist.namePlaceholder()
        
        if let genre = artist.genre {
            genreLabel.text = Const.artistGenre.appending(genre)
        }
        
        linkTextView.attributedText = artist.attributedLinkText()
        moreFromArtistLabel.text = artist.moreFromArtistPlaceHolder()
    }
    
    func showMoreFromArtistLabel() {
        moreFromArtistLabel.isHidden = false
    }
}
