import UIKit

final class ViewAnimator {
    
    // MARK: - Static Properties
    
    static let shared = ViewAnimator()
    
    // MARK: - Private Initialisers
    
    private init() {}
}

// MARK: - Methods

extension ViewAnimator {
    
    func animateButtonAction(_ button: UIButton, action: (() -> Void)?) {
        UIView.animate(withDuration: 0.25) {
            button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            action?()
            UIView.animate(withDuration: 0.25) {
                button.transform = .identity
            }
        }
    }
    
    func animateTextViewInteraction(_ textView: UITextView, openURL url: URL) {
        UIView.animate(withDuration: 0.25) {
            textView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        } completion: { _ in
            UIApplication.shared.open(url)
            UIView.animate(withDuration: 0.25) {
                textView.transform = .identity
            }
        }
    }
    
    func animateSelection(for view: UIView, completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.2) {
            view.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            completion?()
            UIView.animate(withDuration: 0.2) {
                view.transform = .identity
            }
        }
    }
    
    func animateHighlight(for cell: UICollectionViewCell) {
        UIView.animate(withDuration: 0.2) {
            cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }
    }
    
    func animateUnhighlight(for cell: UICollectionViewCell) {
        UIView.animate(withDuration: 0.2) {
            cell.transform = .identity
        }
    }
    
    func animateCellAppearance(_ cell: UICollectionViewCell) {
        cell.transform = CGAffineTransform(translationX: 0, y: 50)
        cell.alpha = .zero
        
        let animator = UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.9) {
            cell.transform = .identity
            cell.alpha = 1
        }
        animator.startAnimation()
    }
    
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
