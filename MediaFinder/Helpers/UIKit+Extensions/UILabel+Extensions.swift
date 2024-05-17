import UIKit

// MARK: - Label Animations

extension UILabel {
    
    func animateLabelExpansion(with moreButton: UIButton) {
        guard let text, text.count > 140 else { return }
        
        let prefixText = String(text.prefix(140))
        let suffixText = text.suffix(from: text.index(text.startIndex, offsetBy: 140))
        
        numberOfLines = .zero
        moreButton.isHidden = true
        
        self.text = prefixText
        
        suffixText.forEach {
            self.text?.append($0)
            RunLoop.current.run(until: Date() + 0.007)
        }
    }
}
