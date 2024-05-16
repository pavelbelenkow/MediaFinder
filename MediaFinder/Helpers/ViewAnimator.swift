import UIKit

final class ViewAnimator {
    
    // MARK: - Static Properties
    
    static let shared = ViewAnimator()
    
    // MARK: - Private Initialisers
    
    private init() {}
}

// MARK: - Methods

extension ViewAnimator {
    
    func animateLabelExpansion(_ label: UILabel, moreButton: UIButton) {
        guard let text = label.text else { return }
        
        var prefixText = String(text.prefix(140))
        let suffixText = text.suffix(from: .init(utf16Offset: 140, in: text))
        
        moreButton.isHidden = true
        label.numberOfLines = .zero
        
        suffixText.forEach {
            prefixText += "\($0)"
            label.text = prefixText
            RunLoop.current.run(until: Date() + 0.007)
        }
    }
}
