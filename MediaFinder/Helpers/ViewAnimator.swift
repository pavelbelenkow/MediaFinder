import UIKit

final class ViewAnimator {
    
    // MARK: - Static Properties
    
    static let shared = ViewAnimator()
    
    // MARK: - Private Properties
    
    private let notificationCenter: NotificationCenter
    
    private var shimmerLayers: [UIView: CAGradientLayer] = [:]
    
    private var animationStartTime: CFTimeInterval = 0
    private var words: [String] = []
    private var label: UILabel?
    private var displayLink: CADisplayLink?
    
    // MARK: - Private Initialisers
    
    private init(notificationCenter: NotificationCenter = .default) {
        self.notificationCenter = notificationCenter
    }
}

// MARK: - Private Methods

private extension ViewAnimator {
    
    func resumeShimmering(for view: UIView) {
        guard let gradientLayer = shimmerLayers[view] else { return }
        
        let animation = CABasicAnimation(keyPath: Const.locationsKeyPath)
        animation.fromValue = gradientLayer.presentation()?.value(forKey: Const.locationsKeyPath)
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradientLayer.add(animation, forKey: Const.shimmerAnimationKey)
    }
    
    func pauseShimmering(for view: UIView) {
        guard let gradientLayer = shimmerLayers[view] else { return }
        gradientLayer.removeAllAnimations()
    }
    
    func addObservers(for view: UIView) {
        notificationCenter
            .addObserver(
                forName: UIApplication.willEnterForegroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.resumeShimmering(for: view)
            }
        
        notificationCenter
            .addObserver(
                forName: UIApplication.didEnterBackgroundNotification,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.pauseShimmering(for: view)
            }
    }
    
    @objc func updateLabel() {
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

// MARK: - Methods

extension ViewAnimator {
    
    func animateWithShimmer(_ view: UIView) {
        guard shimmerLayers[view] == nil else { return }
        
        let gradient = CAGradientLayer()
        let viewSize = view.bounds.size
        let radians = 45.0 * .pi / 180
        let x = cos(CGFloat(radians))
        let y = sin(CGFloat(radians))
        
        gradient.frame = CGRect(
            x: -viewSize.width,
            y: 0,
            width: 3 * viewSize.width,
            height: viewSize.height
        )
        gradient.startPoint = CGPoint(x: 1.0 - x, y: 1.0 - y)
        gradient.endPoint = CGPoint(x: x, y: y)
        gradient.locations = [-1.0, -0.5, 0.0]
        gradient.colors = [
            UIColor.mediaBackground.cgColor,
            UIColor(white: 0.75, alpha: 1.0).cgColor,
            UIColor.mediaBackground.cgColor
        ]
        
        view.layer.addSublayer(gradient)
        shimmerLayers[view] = gradient
        
        let animation = CABasicAnimation(keyPath: Const.locationsKeyPath)
        animation.fromValue = [-1.0, -0.5, 0.0]
        animation.toValue = [1.0, 1.5, 2.0]
        animation.duration = 1.5
        animation.repeatCount = .infinity
        gradient.add(animation, forKey: Const.shimmerAnimationKey)
        
        addObservers(for: view)
    }
    
    func stopAnimatingWithShimmer(_ view: UIView) {
        guard let gradientLayer = shimmerLayers[view] else { return }
        gradientLayer.removeFromSuperlayer()
        shimmerLayers.removeValue(forKey: view)
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
}
