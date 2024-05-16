import UIKit

// MARK: = RunLoop Animations

extension UILabel {
    
    func animateLabelExpansion(with moreButton: UIButton) {
        guard let text else { return }
        
        var prefixText = String(text.prefix(140))
        let suffixText = text.suffix(from: .init(utf16Offset: 140, in: text))
        
        numberOfLines = .zero
        moreButton.isHidden = true
        
        suffixText.forEach {
            prefixText += "\($0)"
            self.text = prefixText
            RunLoop.current.run(until: Date() + 0.007)
        }
    }
}
