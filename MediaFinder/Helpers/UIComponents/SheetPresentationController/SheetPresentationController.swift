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
    
    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = .zero
        return view
    }()
    
    private let grabberView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray3
        view.layer.cornerRadius = 2.5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let recognizer = UIPanGestureRecognizer()
        recognizer.addTarget(self, action: #selector(handlePanGesture(_:)))
        return recognizer
    }()
    
    private var currentDetent: Detent = .medium
    private var startingHeight: CGFloat = .zero
    
    private var mediumHeight: CGFloat {
        guard let containerView else { return .zero }
        return containerView.bounds.height * 0.5
    }
    
    private var largeHeight: CGFloat {
        guard let containerView else { return .zero }
        return containerView.bounds.height * 0.9
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
        guard let containerView else { return }
        
        dimmingView.frame = containerView.bounds
        
        containerView.addSubview(dimmingView)
        containerView.addSubview(presentedViewController.view)
        
        presentedViewController.view.frame = frameOfPresentedViewInContainerView
        presentedViewController.view.layer.cornerRadius = 10
        presentedViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedViewController.view.layer.masksToBounds = true
        
        setupGrabberView()
    }
}

// MARK: - Private Methods

private extension SheetPresentationController {
    
    func setupGrabberView() {
        presentedViewController.view.addSubview(grabberView)
        NSLayoutConstraint.activate([
            grabberView.widthAnchor.constraint(equalToConstant: 32),
            grabberView.heightAnchor.constraint(equalToConstant: 4.5),
            grabberView.topAnchor.constraint(equalTo: presentedViewController.view.topAnchor, constant: 4),
            grabberView.centerXAnchor.constraint(equalTo: presentedViewController.view.centerXAnchor)
        ])
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
