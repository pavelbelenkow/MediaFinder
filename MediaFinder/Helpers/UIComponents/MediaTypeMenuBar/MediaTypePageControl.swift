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

private extension MediaTypePageControl {
    
    func updateView() {
        translatesAutoresizingMaskIntoConstraints = false
        createButton()
        setupSelectorView()
        setupStackView()
    }
    
    func setupSelectorView() {
        let selectorWidth = frame.width / CGFloat(buttonTitles.count)
        selectorView = UIView(frame: CGRect(x: 0, y: frame.height, width: selectorWidth, height: 4))
        selectorView.backgroundColor = .black
        addSubview(selectorView)
    }
    
    func setupStackView() {
        let stack = UIStackView(arrangedSubviews: buttons)
        stack.axis = .horizontal
        stack.spacing = Const.spacingSmall
        stack.distribution = .fillEqually
        addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.topAnchor.constraint(equalTo: topAnchor).isActive = true
        stack.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        stack.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        stack.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
    }
    
    func createButton() {
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        buttonTitles.enumerated().forEach { index, buttonTitle in
            let button = UIButton(type: .custom)
            button.setTitle(buttonTitle, for: .normal)
            button.titleLabel?.font = .boldSystemFont(ofSize: 19)
            button.addTarget(self, action: #selector(buttonAction), for: .touchUpInside)
            button.setTitleColor(index == selectedIndex ? .white : .lightText, for: .normal)
            buttons.append(button)
        }
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
