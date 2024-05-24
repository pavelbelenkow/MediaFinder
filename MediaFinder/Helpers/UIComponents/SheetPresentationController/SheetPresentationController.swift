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
    
    private let grabberView: UIView = {
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
    
    // MARK: - Overridden Initialisers
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        presentedViewController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    // MARK: - Lifecycle
    
    override func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        guard let containerView, let presentedView else { return }
        
        containerView.addSubview(presentedView)
        presentedView.addSubview(grabberView)
        
        grabberView.frame.origin.y = 4
        grabberView.center.x = presentedView.center.x
        
        presentedView.frame = frameOfPresentedViewInContainerView
        presentedView.layer.cornerRadius = 10
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView.layer.masksToBounds = true
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = 0.3
        containerView.layer.shadowOffset = CGSize(width: 0, height: -4)
        containerView.layer.shadowRadius = 10
        
        presentedViewController.additionalSafeAreaInsets.top = grabberView.frame.maxY / 2
    }
    }
}

// MARK: - Private Methods

private extension SheetPresentationController {
    
    }
    
    func animate(to detent: Detent) {
        guard let presentedView, let containerView else { return }
        
        let isMediumDetent = detent == .medium
        let height = isMediumDetent ? mediumHeight : largeHeight
        
        let scaledTransform = CGAffineTransform(scaleX: 0.9, y: 0.92)
        let transform = isMediumDetent ? .identity : scaledTransform
        let translatedTransform = isMediumDetent ? .identity : scaledTransform.translatedBy(x: .zero, y: -26)
        
        UIView.animate(
            withDuration: 0.6,
            delay: .zero,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 1.0,
            options: .curveEaseOut
        ) { [weak self] in
            guard let self else { return }
            
            presentedView.frame.size.height = height
            presentedView.frame.origin.y = containerView.frame.height - height
            presentingViewController.presentingViewController?.view.transform = transform
            presentingViewController.view.transform = translatedTransform
            presentingViewController.view.layer.cornerRadius = 10
            currentDetent = detent
        }
    }
    
    func updatePresentingViewControllerTransform() {
        guard let presentedView else { return }
        
        let currentHeight = presentedView.frame.height - mediumHeight
        let heightRange = largeHeight - mediumHeight
        let heightRatio = currentHeight / heightRange
        
        let scale = 1 - heightRatio * 0.1
        let scaledTransform = CGAffineTransform(scaleX: scale, y: scale)
        
        presentingViewController.presentingViewController?.view.transform = scaledTransform
        presentingViewController.view.transform = scaledTransform.translatedBy(x: .zero, y: -26 * heightRatio)
    }
    
    @objc
    func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard  let containerView, let presentedView else { return }
        
        switch gestureRecognizer.state {
        case .began:
            startingHeight = presentedView.frame.height
        case .changed:
            let translation = gestureRecognizer.translation(in: presentedView)
            let newHeight = startingHeight - translation.y
            if newHeight >= largeHeight {
                presentedView.frame.size.height = newHeight
                currentDetent = .large
            } else if newHeight <= mediumHeight {
                presentedView.frame.size.height = mediumHeight
                currentDetent = .medium
            } else {
                presentedView.frame.size.height = newHeight
            }
            presentedView.frame.origin.y = containerView.frame.height - presentedView.frame.height
            updatePresentingViewControllerTransform()
        case .ended, .cancelled:
            let velocity = gestureRecognizer.velocity(in: presentedView)
            
            if velocity.y > 0 {
                if currentDetent == .medium {
                    presentedViewController.dismiss(animated: true)
                } else {
                    animate(to: .medium)
                }
            } else {
                animate(to: .large)
            }
        default:
            break
        }
    }
}
