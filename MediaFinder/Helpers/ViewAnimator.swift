import UIKit

final class ViewAnimator {
    
    static let shared = ViewAnimator()
    
    private let notificationCenter: NotificationCenter
    
    private var animationStartTime: CFTimeInterval = 0
    private var words: [String] = []
    private var label: UILabel?
    private var displayLink: CADisplayLink?
    
    private var shimmerLayers: [UIView: CAGradientLayer] = [:]
    
    private init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }
    
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
        self.label = label
        
        guard
            let words = label.text?.components(separatedBy: .whitespacesAndNewlines),
            !words.isEmpty
        else { return }
        
        self.words = words
        
        moreButton.isHidden = true
        label.numberOfLines = .zero
        
        animationStartTime = CACurrentMediaTime()
        displayLink = CADisplayLink(target: self, selector: #selector(updateLabel))
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc private func updateLabel() {
        guard let displayLink, let label else { return }
        
        let duration = 1.0
        let elapsedTime = CACurrentMediaTime() - animationStartTime
        let progress = min(elapsedTime / duration, 1.0)
        
        let totalWordsCount = words.count
        let wordsToShowCount = Int(Double(totalWordsCount) * progress)
        
        let displayText = words.prefix(wordsToShowCount).joined(separator: " ")
        
        label.text = displayText
        
        if progress >= 1.0 {
            displayLink.invalidate()
            self.displayLink = nil
        }
    }
}
    func resumeShimmering(for view: UIView) {
        guard let gradientLayer = shimmerLayers[view] else { return }
        
        let animation = CABasicAnimation(keyPath: Const.locationsKeyPath)
        animation.fromValue = gradientLayer.presentation()?.value(forKey: Const.locationsKeyPath)
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: Const.shimmerAnimationKey)
    }
