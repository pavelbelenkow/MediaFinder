import UIKit

final class CustomButton: UIButton {
    
    // MARK: - Private Properties
    
    private var url: URL?
    
    // MARK: - Configure Button
    
    func configure(urlString: String, with attributedString: NSAttributedString) {
        self.url = URL(string: urlString)
        
        backgroundColor = .clear
        contentHorizontalAlignment = .leading
        
        setAttributedTitle(attributedString, for: .normal)
        setTitleColor(.systemBlue, for: .normal)
        addTarget(
            self,
            action: #selector(buttonTapped),
            for: .touchUpInside
        )
    }
}

// MARK: - Private Methods

private extension CustomButton {
    
    @objc func buttonTapped() {
        guard let url else { return }
        
        animateSelection {
            UIApplication.shared.open(url)
        }
    }
}
