import UIKit

final class MediaTypeMenuCell: UICollectionViewCell {
    
    // MARK: - Private Properties
    
    private lazy var mediaTypeLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightText
        label.font = .boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Overridden Properties
    
    override var isSelected: Bool {
        didSet {
            mediaTypeLabel.textColor = isSelected ? .white : .lightText
        }
    }
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI

private extension MediaTypeMenuCell {
    
    func setupAppearance() {
        contentView.addSubview(mediaTypeLabel)
        
        NSLayoutConstraint.activate([
            mediaTypeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            mediaTypeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}

// MARK: - Methods

extension MediaTypeMenuCell {
    
    func configure(with text: String) {
        mediaTypeLabel.text = text
    }
}
