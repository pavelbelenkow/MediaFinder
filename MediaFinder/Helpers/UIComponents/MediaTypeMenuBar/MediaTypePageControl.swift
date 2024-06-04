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

// MARK: - Private Methods

private extension MediaTypePageControl {
    
    @objc func buttonAction(sender: UIButton) {
        guard let tappedButtonIndex = buttons.firstIndex(of: sender) else { return }
        handleSelectionChange(to: tappedButtonIndex)
    }
    
    func animateSelectionChange(to newIndex: Int) {
        buttons[newIndex].animateSelection {
            self.selectedIndex = newIndex
            self.delegate?.change(to: newIndex)
        }
    }
    
    func updateSelectorPosition(to newIndex: Int) {
        let selectorPosition = frame.width / CGFloat(buttonTitles.count) * CGFloat(newIndex)
        UIView.animate(withDuration: 0.25) {
            self.selectorView.frame.origin.x = selectorPosition
            self.selectorView.alpha = 0.6
            self.selectorView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            UIView.animate(withDuration: 0.25) {
                self.selectorView.alpha = 1.0
                self.selectorView.transform = .identity
            }
        }
    }
    
    func updateButtonAppearance(for newIndex: Int) {
        buttons.enumerated().forEach { index, button in
            UIView.animate(withDuration: 0.25) {
                let isSelected = index == newIndex
                button.setTitleColor(isSelected ? .white : .lightText, for: .normal)
                button.transform = isSelected ? CGAffineTransform(scaleX: 0.8, y: 0.8) : .identity
            }
        }
    }
}

// MARK: - Methods

extension MediaTypePageControl {
    
    func handleSelectionChange(to newIndex: Int) {
        guard newIndex != selectedIndex else { return }
        animateSelectionChange(to: newIndex)
        updateSelectorPosition(to: newIndex)
        updateButtonAppearance(for: newIndex)
    }
}
