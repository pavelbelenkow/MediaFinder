import UIKit

final class CustomLabel: UILabel {
    
    // MARK: - Configure Label
    
    func configure(
        textColor: UIColor = .black,
        font: UIFont = .systemFont(ofSize: 17),
        alignment: NSTextAlignment = .center,
        numberOfLines: Int = .zero
    ) {
        self.textColor = textColor
        self.font = font
        self.textAlignment = alignment
        self.numberOfLines = numberOfLines
    }
}
