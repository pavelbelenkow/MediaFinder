import UIKit

// MARK: - Delegates

protocol StatefulStackViewDelegate: AnyObject {
    func didTapRepeatButton()
}

final class StatefulStackView: UIStackView {
    
    // MARK: - Private Properties
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView()
        view.style = .medium
        view.color = .white
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = Const.noResultsTitle
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = .zero
        return label
    }()
    
    private lazy var repeatButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle(Const.repeatButtonTitle, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.layer.borderWidth = Const.repeatButtonBorderWidth
        button.layer.cornerRadius = Const.repeatButtonCornerRadius
        button.addTarget(self, action: #selector(repeatButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Properties
    
    weak var delegate: StatefulStackViewDelegate?
    
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

private extension StatefulStackView {
    
    func setupAppearance() {
        axis = .vertical
        spacing = Const.spacingSmall
        translatesAutoresizingMaskIntoConstraints = false
        
        [activityIndicatorView, titleLabel, descriptionLabel, repeatButton].forEach { addArrangedSubview($0) }
    }
    
    func updateActivityIndicatorView(for state: State) {
        let isLoading = state == .loading
        
        UIView.animate(withDuration: 0.2) {
            self.activityIndicatorView.alpha = isLoading ? 1 : 0
            isLoading ? self.activityIndicatorView.startAnimating() : self.activityIndicatorView.stopAnimating()
        }
    }
    
    func updateTitleLabel(for state: State, isEmptyResults: Bool) {
        titleLabel.isHidden = !(state == .loaded && isEmptyResults)
    }
    
    func updateDescriptionLabel(for state: State, isEmptyResults: Bool) {
        
        descriptionLabel.isHidden = {
            switch state {
            case .loading,
                    .loaded where isEmptyResults,
                    .error: false
            default: true
            }
        }()
        
        descriptionLabel.text = {
            switch state {
            case .loading : Const.loadingDescription
            case .loaded where isEmptyResults: Const.noResultsDescription
            case .error(let errorMessage): errorMessage
            default: nil
            }
        }()
        
        descriptionLabel.textColor = {
            switch state {
            case .loading: .white
            case .loaded where isEmptyResults: .darkGray
            default: .black
            }
        }()
    }
    
    func updateRepeatButton(for state: State) {
        repeatButton.isHidden = {
            switch state {
            case .error: false
            default: true
            }
        }()
    }
}

// MARK: - Private Methods

private extension StatefulStackView {
    
    @objc func repeatButtonTapped() {
        delegate?.didTapRepeatButton()
    }
}

// MARK: - Methods

extension StatefulStackView {
    
    func update(for state: State, isEmptyResults: Bool) {
        updateActivityIndicatorView(for: state)
        updateTitleLabel(for: state, isEmptyResults: isEmptyResults)
        updateDescriptionLabel(for: state, isEmptyResults: isEmptyResults)
        updateRepeatButton(for: state)
    }
}
