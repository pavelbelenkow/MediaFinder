import UIKit

final class ArtistInfoView: UIStackView {
    
    // MARK: - Private Properties
    
    private lazy var titleLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(font: .boldSystemFont(ofSize: 21), alignment: .left)
        return label
    }()
    
    private lazy var nameLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            font: .systemFont(ofSize: 19, weight: .medium),
            alignment: .left
        )
        return label
    }()
    
    private lazy var genreLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            textColor: .mediaRed,
            font: .systemFont(ofSize: 18),
            alignment: .left
        )
        return label
    }()
    
    private lazy var linkTextView: CustomTextView = {
        let textView = CustomTextView()
        textView.configure()
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

private extension ArtistInfoView {
    
    func setupAppearance() {
        backgroundColor = .white
        axis = .vertical
        spacing = Const.spacingSmall
        layer.cornerRadius = 10
        clipsToBounds = true
        isHidden = true
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = UIEdgeInsets(
            top: Const.spacingMedium, left: Const.spacingMedium,
            bottom: Const.spacingMedium, right:  Const.spacingMedium
        )
        
        [titleLabel, nameLabel, genreLabel, linkTextView].forEach { addArrangedSubview($0) }
    }
}

// MARK: - Methods

extension ArtistInfoView {
    
    func update(for artist: Artist) {
        titleLabel.text = Const.aboutArtist.appending(artist.kind)
        nameLabel.text = artist.namePlaceholder()
        genreLabel.text = Const.artistGenre.appending(artist.genre)
        linkTextView.attributedText = artist.attributedLinkText()
        isHidden = false
    }
}
