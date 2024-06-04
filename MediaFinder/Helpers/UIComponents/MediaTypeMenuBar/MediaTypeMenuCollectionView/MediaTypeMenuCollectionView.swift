import UIKit

// MARK: - Delegates

protocol MediaTypeMenuCollectionViewDelegate: AnyObject {
    func didSelectMediaTypeMenu(at index: Int)
}

final class MediaTypeMenuCollectionView: UICollectionView {
    
    // MARK: - Properties
    
    weak var interactionDelegate: MediaTypeMenuCollectionViewDelegate?
    
    // MARK: - Initializers
    
    init() {
        let layout = UICollectionViewFlowLayout()
        super.init(frame: .zero, collectionViewLayout: layout)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI

private extension MediaTypeMenuCollectionView {
    
    func setupAppearance() {
        if let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.scrollDirection = .horizontal
            flowLayout.minimumLineSpacing = .zero
        }
        
        backgroundColor = .clear
        
        register(
            MediaTypeMenuCell.self,
            forCellWithReuseIdentifier: Const.mediaTypeMenuCellReuseIdentifier
        )
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        translatesAutoresizingMaskIntoConstraints = false
        
        dataSource = self
        delegate = self
    }
}

// MARK: - DataSource Methods

extension MediaTypeMenuCollectionView: UICollectionViewDataSource {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        Const.mediaTypeButtonTitles.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        
        guard
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: Const.mediaTypeMenuCellReuseIdentifier,
                for: indexPath) as? MediaTypeMenuCell
        else { return UICollectionViewCell() }
        
        let firstItem = IndexPath(item: .zero, section: .zero)
        collectionView.selectItem(
            at: firstItem,
            animated: false,
            scrollPosition: .left
        )
        
        let title = Const.mediaTypeButtonTitles[indexPath.item]
        cell.configure(with: title)
        
        return cell
    }
}
