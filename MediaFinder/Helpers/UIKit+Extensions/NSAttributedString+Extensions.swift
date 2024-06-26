import UIKit

extension NSAttributedString {
    
    static func underlinedText(_ text: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 16),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ], range: range)
        
        return attributedString
    }
    
    static func attributedTextWithLineSpacing(text: String, spacing: CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.lineSpacing = spacing
        attributedString.addAttribute(
            .paragraphStyle,
            value: paragraphStyle,
            range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
}
