import UIKit

extension NSAttributedString {
    
    static func attributedLinkText(placeholder: String, link: String) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: placeholder)
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttributes([
            .font: UIFont.boldSystemFont(ofSize: 16),
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .link: link
        ], range: range)
        
        return attributedString
    }
}
