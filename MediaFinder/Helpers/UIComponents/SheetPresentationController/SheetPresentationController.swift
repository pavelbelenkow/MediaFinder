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
        setupAppearance(containerView: containerView, presentedView: presentedView)
    }
    
    override func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        resetPresentingViewControllers()
    }
}

// MARK: - Setup UI

private extension SheetPresentationController {
    
    func setupAppearance(containerView: UIView, presentedView: UIView) {
        setupShadow(to: containerView)
        setupPassthroughTouchView(in: containerView)
        setupPresentedView(presentedView)
        setupGrabberView(in: presentedView)
    }
    
    func setupShadow(to containerView: UIView) {
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 0, height: -4)
        containerView.layer.shadowRadius = 10
    }
    
    func setupPassthroughTouchView(in containerView: UIView) {
        containerView.addSubview(passthroughTouchView)
        passthroughTouchView.frame = containerView.bounds
    }
    
    func setupPresentedView(_ presentedView: UIView) {
        containerView?.addSubview(presentedView)
        presentedView.frame = frameOfPresentedViewInContainerView
        presentedView.layer.cornerRadius = 10
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView.layer.masksToBounds = true
    }
    
    func setupGrabberView(in presentedView: UIView) {
        presentedView.addSubview(grabberView)
        grabberView.frame.origin.y = 4
        grabberView.center.x = presentedView.center.x
        presentedViewController.additionalSafeAreaInsets.top = grabberView.frame.maxY / 2
    }
}

// MARK: - Private Methods

private extension SheetPresentationController {
    
    func updatePresentingViews(
        with transform: CGAffineTransform,
        translatedTransform: CGAffineTransform = .identity,
        animated: Bool = false
    ) {
        var presentingVC = presentingViewController.presentingViewController
        
        let updateBlock = { [weak self] in
            guard let self else { return }
            
            while let vc = presentingVC {
                vc.view.transform = transform
                presentingVC = vc.presentingViewController
            }
            
            presentingViewController.view.transform = translatedTransform.isIdentity ? .identity : translatedTransform
            presentingViewController.view.layer.cornerRadius = transform.isIdentity ? 0 : 10
        }
        
        if animated && transform.isIdentity {
            UIView.animate(withDuration: 0.3, animations: updateBlock)
        } else {
            updateBlock()
        }
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
    
    func handleChangedGesture(
        for presentedView: UIView,
        containerView: UIView,
        with newHeight: CGFloat
    ) {
        if newHeight >= mediumHeight && newHeight <= largeHeight {
            presentedView.frame.size.height = newHeight
            presentedView.frame.origin.y = containerView.bounds.height - newHeight
            updatePresentingViewControllerTransform(for: newHeight)
        } else if newHeight < mediumHeight {
            presentedView.frame.size.height = newHeight
            presentedView.frame.origin.y = containerView.bounds.height - newHeight
        }
    }
    
    func shouldDismissView(for velocity: CGFloat, currentHeight: CGFloat) -> Bool{
        let isFastSwipe = abs(velocity) > 2000
        return (isFastSwipe && velocity > 0) || currentHeight < mediumHeight / 2
    }
    
    func determineTargetDetent(for velocity: CGFloat, currentHeight: CGFloat) -> Detent {
        let midHeight = (mediumHeight + largeHeight) / 2
        return (velocity > 0 || currentHeight < midHeight) ? .medium : .large
    }
    
    func handleEndedGesture(for presentedView: UIView, velocity: CGPoint) {
        let currentHeight = presentedView.frame.height
        let shouldDismiss = shouldDismissView(for: velocity.y, currentHeight: currentHeight)
        
        
        if shouldDismiss {
            presentedViewController.dismiss(animated: true)
        } else {
            let targetDetent = determineTargetDetent(for: velocity.y, currentHeight: currentHeight)
            let animationDuration = calculateAnimationDuration(for: velocity.y)
            animate(to: targetDetent, duration: animationDuration)
        }
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
            handleChangedGesture(
                for: presentedView,
                containerView: containerView,
                with: newHeight
            )
        case .ended, .cancelled:
            handleEndedGesture(for: presentedView, velocity: velocity)
        default:
            break
        }
    }
}
