import UIKit

protocol MediaInfoViewDelegate: AnyObject {
    func didTapMoreButton(_ model: DetailedDescription)
}

final class MediaInfoView: UIStackView {
    
    // MARK: - Private Properties
    
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
            textColor: .white,
            font: .systemFont(ofSize: 19, weight: .medium),
            backgroundColor: .black,
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
        button.backgroundColor = .white
        button.titleLabel?.font = .systemFont(ofSize: 13)
        button.setTitle(Const.moreButtonText.uppercased(), for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(
            self,
            action: #selector(moreButtonTapped),
            for: .touchUpInside
        )
        button.layer.addShadow(
            color: UIColor.white.cgColor,
            offset: CGSize(width: -8, height: .zero),
            opacity: 1
        )
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var linkButton = CustomButton()
    
    private lazy var mediaStackView: UIStackView = {
        let view = UIStackView(arrangedSubviews: [
            kindLabel, nameLabel, artistNameLabel,
            descriptionLabel, linkButton
        ])
        view.backgroundColor = .white
        view.layer.cornerRadius = Const.repeatButtonCornerRadius
        view.axis = .vertical
        view.alignment = .center
        view.spacing = Const.spacingMedium
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .medium
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    weak var delegate: MediaInfoViewDelegate?
    
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
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .medium
        
        addArrangedSubview(mediaStackView)
    }
    
    func setupMoreButton() {
        mediaStackView.addSubview(moreButton)
        
        NSLayoutConstraint.activate([
            moreButton.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            moreButton.firstBaselineAnchor.constraint(equalTo: descriptionLabel.lastBaselineAnchor)
        ])
    }
    
    @objc func moreButtonTapped() {
        guard
            let name = nameLabel.text,
            let description = descriptionLabel.attributedText
        else { return }
        
        let model = DetailedDescription(mediaName: name, attributedDescription: description)
        delegate?.didTapMoreButton(model)
    }
}

// MARK: - Methods

extension MediaInfoView {
    
    func update(for media: Media) {
        guard
            let kind = media.kind,
            let name = media.name,
            let _ = media.artist,
            let link = media.trackView
        else { return }
        
        kindLabel.text = kind
        nameLabel.text = name
        artistNameLabel.text = media.artistNamePlaceholder()
        
        descriptionLabel.isHidden = media.description == nil
        descriptionLabel.attributedText = media.attributedDescription()
        media.attributedDescription().string.count > 140 ? setupMoreButton() : nil
        
        linkButton.configure(urlString: link, with: media.underlinedLinkText())
    }
    
    func applyColors(_ colors: ImageColors) {
        mediaStackView.backgroundColor = colors.primary
        kindLabel.textColor = colors.secondary
        nameLabel.backgroundColor = colors.background
        nameLabel.textColor = colors.primary
        artistNameLabel.textColor = colors.secondary
        descriptionLabel.textColor = colors.detail
        moreButton.backgroundColor = colors.primary
        moreButton.layer.shadowColor = colors.primary.cgColor
        moreButton.setTitleColor(colors.secondary, for: .normal)
        linkButton.setTitleColor(colors.secondary, for: .normal)
    }
}
