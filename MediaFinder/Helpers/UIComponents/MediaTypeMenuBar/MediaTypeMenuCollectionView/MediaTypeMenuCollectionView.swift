import UIKit

// MARK: - Delegates

protocol MediaTypeMenuCollectionViewDelegate: AnyObject {
    func didSelectMediaTypeMenu(at index: Int)
}
