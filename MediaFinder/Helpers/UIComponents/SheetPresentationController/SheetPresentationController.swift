import UIKit

final class SheetPresentationController: UIPresentationController {
    
    enum Detent {
        case medium
        case large
        
        var heightRatio: CGFloat {
            switch self {
                case .medium: 0.5
                case .large: 0.9
            }
        }
    }
    
    // MARK: - Private Properties
    
    private lazy var passthroughTouchView = PassthroughTouchView(targetViews: [
        presentingViewController.view
    ])
    
    private lazy var grabberView: UIView = {
        let view = UIView()
        view.bounds.size = CGSize(width: 32, height: 4.5)
        view.backgroundColor = .systemFill
        view.layer.cornerRadius = view.frame.height / 2
        return view
    }()
    
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(
        target: self,
        action: #selector(handlePanGesture(_:))
    )
    
    private var currentDetent: Detent = .medium
    private var initialFrame: CGRect = .zero
    private var initialTranslation: CGFloat = .zero
    
    private var mediumHeight: CGFloat {
        guard let containerView else { return .zero }
        return containerView.bounds.height * Detent.medium.heightRatio
    }
    
    private var largeHeight: CGFloat {
        guard let containerView else { return .zero }
        return containerView.bounds.height * Detent.large.heightRatio
    }
    
    // MARK: - Overridden Properties
    
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView else { return .zero }
        return CGRect(
            x: .zero,
            y: containerView.bounds.height - mediumHeight,
            width: containerView.bounds.width,
            height: mediumHeight
        )
    }
    
    // MARK: - Overridden Initializers
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Lifecycle
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView, let presentedView else { return }
         
    func setupShadow(to containerView: UIView) {
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 0, height: -4)
        containerView.layer.shadowRadius = 10
    }
        containerView.addSubview(passthroughTouchView)
        containerView.addSubview(presentedView)
        presentedView.addSubview(grabberView)
        
        passthroughTouchView.frame = containerView.bounds
        
        presentedView.frame = frameOfPresentedViewInContainerView
        presentedView.layer.cornerRadius = 10
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView.layer.masksToBounds = true
        
        grabberView.frame.origin.y = 4
        grabberView.center.x = presentedView.center.x
        presentedViewController.additionalSafeAreaInsets.top = grabberView.frame.maxY / 2
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        resetPresentingViewControllers()
    }
}

// MARK: - Private Methods

private extension SheetPresentationController {
    
    func resetPresentingViewControllers() {
        var presentingVC = presentingViewController.presentingViewController
        
        while let vc = presentingVC {
            UIView.animate(withDuration: 0.3) {
                vc.view.transform = .identity
            }
            presentingVC = vc.presentingViewController
        }
        
        UIView.animate(withDuration: 0.3) {
            self.presentingViewController.view.transform = .identity
            self.presentingViewController.view.layer.cornerRadius = .zero
        }
    }
    
    func updatePresentingViewControllersTransform(transform: CGAffineTransform, translatedTransform: CGAffineTransform) {
        var presentingVC = presentingViewController.presentingViewController
        
        while let vc = presentingVC {
            vc.view.transform = transform
            presentingVC = vc.presentingViewController
        }
        
        presentingViewController.view.transform = translatedTransform
        presentingViewController.view.layer.cornerRadius = 10
    }
    
    func updatePresentingViewControllerTransform(for currentHeight: CGFloat) {
        
        let heightDifference = largeHeight - mediumHeight
        let heightRatio = (currentHeight - mediumHeight) / heightDifference
        
        let scale = 1 - heightRatio * 0.1
        let scaledTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        updatePresentingViewControllersTransform(
            transform: scaledTransform,
            translatedTransform: scaledTransform.translatedBy(x: .zero, y: -26 * heightRatio)
        )
    }
    
    func animate(to detent: Detent, duration: TimeInterval) {
        guard let presentedView, let containerView else { return }
        
        let isMediumDetent = detent == .medium
        let height = isMediumDetent ? mediumHeight : largeHeight
        
        let scaledTransform = CGAffineTransform(scaleX: 0.9, y: 0.92)
        let transform = isMediumDetent ? .identity : scaledTransform
        let translatedTransform = isMediumDetent ? .identity : scaledTransform.translatedBy(x: .zero, y: -26)
        
        UIView.animate(
            withDuration: duration,
            delay: .zero,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 1.0,
            options: .curveEaseOut
        ) { [weak self] in
            guard let self else { return }
            
            presentedView.frame.size.height = height
            presentedView.frame.origin.y = containerView.frame.height - height
            updatePresentingViewControllersTransform(transform: transform, translatedTransform: translatedTransform)
            currentDetent = detent
        }
    }
    
    func calculateAnimationDuration(for velocity: CGFloat) -> TimeInterval {
        let minimumVelocity: CGFloat = 100
        let minimumDuration: TimeInterval = 0.3
        let baseDuration: TimeInterval = 0.6
        let velocityFactor: TimeInterval = 500 / max(abs(velocity), minimumVelocity)
        return min(max(baseDuration * velocityFactor, minimumDuration), baseDuration)
    }

    @objc
    func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let containerView, let presentedView else { return }
        
        let translation = gestureRecognizer.translation(in: presentedView)
        let velocity = gestureRecognizer.velocity(in: presentedView)
        
        switch gestureRecognizer.state {
        case .began:
            initialFrame = presentedView.frame
            initialTranslation = translation.y
        case .changed:
            let newHeight = initialFrame.height - (translation.y - initialTranslation)
            
            if newHeight >= mediumHeight && newHeight <= largeHeight {
                presentedView.frame.size.height = newHeight
                presentedView.frame.origin.y = containerView.bounds.height - newHeight
                updatePresentingViewControllerTransform(for: newHeight)
            } else if newHeight < mediumHeight {
                presentedView.frame.size.height = newHeight
                presentedView.frame.origin.y = containerView.bounds.height - newHeight
            }
        case .ended, .cancelled:
            let currentHeight = presentedView.frame.height
            let isFastSwipe = abs(velocity.y) > 2000
            let shouldDismiss = (isFastSwipe && velocity.y > 0) || currentHeight < mediumHeight / 2
            
            if shouldDismiss {
                presentedViewController.dismiss(animated: true)
            } else {
                let targetDetent: Detent = (velocity.y > 0 || currentHeight < (mediumHeight + largeHeight) / 2)
                ? .medium : .large
                let animationDuration = calculateAnimationDuration(for: velocity.y)
                animate(to: targetDetent, duration: animationDuration)
            }
        default:
            break
        }
    }
}
