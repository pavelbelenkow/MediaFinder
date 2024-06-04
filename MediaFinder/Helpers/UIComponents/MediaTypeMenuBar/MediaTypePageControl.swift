import UIKit

// MARK: - Delegates

protocol MediaTypeMenuBarDelegate: AnyObject {
    func didSelectMediaTypeMenuItem(at index: Int)
}

final class MediaTypeMenuBar: UIView {
    
    // MARK: - Private Properties
    
    private lazy var collectionView: MediaTypeMenuCollectionView = {
        let view = MediaTypeMenuCollectionView()
        view.interactionDelegate = self
        return view
    }()
    
    private lazy var selectorView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.layer.cornerRadius = Const.selectorViewCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var selectorViewLeadingConstraint: NSLayoutConstraint?
    
    // MARK: - Properties
    
    weak var delegate: MediaTypeMenuBarDelegate?
    
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

private extension MediaTypeMenuBar {
    
    func setupAppearance() {
        translatesAutoresizingMaskIntoConstraints = false
        
        setupCollectionView()
        setupSelectorView()
    }
    
    func setupCollectionView() {
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
    
    func setupSelectorView() {
        addSubview(selectorView)
        
        selectorViewLeadingConstraint = selectorView.leadingAnchor.constraint(equalTo: leadingAnchor)
        selectorViewLeadingConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            selectorView.bottomAnchor.constraint(equalTo: bottomAnchor),
            selectorView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: Const.oneFifthMultiplier),
            selectorView.heightAnchor.constraint(equalToConstant: Const.selectorViewHeight)
        ])
    }
}

// MARK: - Methods

extension MediaTypeMenuBar {
    
    func selectMediaTypeMenuItem(at index: Int) {
        collectionView.selectMediaTypeMenu(at: index)
        delegate?.didSelectMediaTypeMenuItem(at: index)
    }
    
    func moveSelectorView(to offset: CGFloat) {
        selectorViewLeadingConstraint?.constant = offset
    }
}
