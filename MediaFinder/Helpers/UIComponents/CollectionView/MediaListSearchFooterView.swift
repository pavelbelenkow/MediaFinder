import UIKit

// MARK: - Delegates

protocol MediaListSearchFooterViewDelegate: AnyObject {
    func didTapRepeatButton()
}

final class MediaListSearchFooterView: UICollectionReusableView {
    
    // MARK: - Private Properties
    
    private lazy var statefulStackView: StatefulStackView = {
        let view = StatefulStackView()
        view.delegate = self
        return view
    }()
    
    // MARK: - Properties
    
    weak var delegate: MediaListSearchFooterViewDelegate?
    
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

private extension MediaListSearchFooterView {
    
    func setupAppearance() {
        addSubview(statefulStackView)
        
        NSLayoutConstraint.activate([
            statefulStackView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor),
            statefulStackView.leadingAnchor.constraint(equalTo: leadingAnchor,
                                                       constant: Const.spacingOneHundred),
            statefulStackView.trailingAnchor.constraint(equalTo: trailingAnchor,
                                                        constant: -Const.spacingOneHundred)
        ])
    }
}

// MARK: - Methods

extension MediaListSearchFooterView {
    
    func updateStackView(for state: State, isEmptyResults: Bool) {
        statefulStackView.update(for: state, isEmptyResults: isEmptyResults)
    }
}

// MARK: - StatefulStackViewDelegate Methods

extension MediaListSearchFooterView: StatefulStackViewDelegate {
    
    func didTapRepeatButton() {
        delegate?.didTapRepeatButton()
    }
}
