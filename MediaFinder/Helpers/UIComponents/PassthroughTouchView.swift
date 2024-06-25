import UIKit

final class PassthroughTouchView: UIView {
    
    // MARK: - Private Properties
    
    private var targetViewsForPassthroughTouches: [UIView] = []
    private var isPassthroughEnabled: Bool = false
    
    // MARK: - Initializers
    
    init(targetViews: [UIView], isPassthroughEnabled: Bool = true) {
        self.targetViewsForPassthroughTouches = targetViews
        self.isPassthroughEnabled = isPassthroughEnabled
        super.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Overridden Methods
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        
        if shouldPassthroughTouch(for: hitView) {
            for targetView in targetViewsForPassthroughTouches {
                if let passthroughTargetView = passthroughTouch(to: targetView, point: point, with: event) {
                    return passthroughTargetView
                }
            }
        }
        
        return hitView
    }
}

// MARK: - Private Methods

private extension PassthroughTouchView {
    
    func shouldPassthroughTouch(for hitView: UIView?) -> Bool {
        hitView == self && isPassthroughEnabled
    }
    
    func passthroughTouch(
        to targetView: UIView,
        point: CGPoint,
        with event: UIEvent?
    ) -> UIView? {
        let convertedPoint = convert(point, to: targetView)
        return targetView.hitTest(convertedPoint, with: event)
    }
}

// MARK: - Methods

extension PassthroughTouchView {
    
    func addTargetView(_ view: UIView) {
        targetViewsForPassthroughTouches.append(view)
    }
    
    func removeTargetView(_ view: UIView) {
        if let index = targetViewsForPassthroughTouches.firstIndex(of: view) {
            targetViewsForPassthroughTouches.remove(at: index)
        }
    }
}
