import UIKit

final class CustomLabel: UILabel {
    
    // MARK: - Override Properties
    
    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + textInsets.left + textInsets.right,
            height: size.height + textInsets.top + textInsets.bottom
        )
    }
    
    // MARK: - Private Properties
    
    private var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    // MARK: - Override Methods
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: textInsets))
    }
    
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
