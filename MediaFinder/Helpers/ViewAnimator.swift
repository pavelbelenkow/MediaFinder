import UIKit

final class ViewAnimator {
    
    static let shared = ViewAnimator()
    
    private init() {}
    
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
}
