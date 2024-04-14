import UIKit

final class CustomTextView: UITextView {
    
    // MARK: - Configure TextView
    
    func configure() {
        backgroundColor = .clear
        tintColor = .black
        dataDetectorTypes = .link
        isEditable = false
        isScrollEnabled = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        delegate = self
    }
}

// MARK: - UITextViewDelegate Methods

extension CustomTextView: UITextViewDelegate {
    
    func textView(
        _ textView: UITextView,
        shouldInteractWith URL: URL,
        in characterRange: NSRange,
        interaction: UITextItemInteraction
    ) -> Bool {
        ViewAnimator.shared.animateTextViewInteraction(textView, openURL: URL)
        return false
    }
}
