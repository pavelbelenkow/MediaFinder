import UIKit

final class DetailedDescriptionView: UIScrollView {
    
    // MARK: - Private Properties
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var descriptionLabel: CustomLabel = {
        let label = CustomLabel()
        label.configure(
            textColor: .gray,
            font: .italicSystemFont(ofSize: 15),
            alignment: .justified
        )
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
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

private extension DetailedDescriptionView {
    
    func setupAppearance() {
        backgroundColor = .white
        isScrollEnabled = false
        panGestureRecognizer.delegate = self
        
        setupContentView()
        setupDescriptionLabel()
    }
    
    func setupContentView() {
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: widthAnchor)
        ])
    }
    
    func setupDescriptionLabel() {
        contentView.addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, 
                                                      constant: Const.spacingThirty),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, 
                                                       constant: -Const.spacingThirty),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}

// MARK: - Methods

extension DetailedDescriptionView {
    
    func updateDescriptionLabel(
        with attributedText: NSAttributedString,
        textColor: UIColor,
        backgroundColor: UIColor
    ) {
        descriptionLabel.attributedText = attributedText
        descriptionLabel.textColor = textColor
        self.backgroundColor = backgroundColor
    }
}

// MARK: - UIGestureRecognizerDelegate Methods

extension DetailedDescriptionView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        contentOffset.y <= .zero
    }
}
