import UIKit

// MARK: - Delegates

protocol MediaListRecentSearchTableViewDelegate: AnyObject {
    func getRecentSearches() -> [String]
    func didTapRecentTerm(at index: Int)
}

final class MediaListRecentSearchTableView: UITableView {
    
    // MARK: - Properties
    
    weak var interactionDelegate: MediaListRecentSearchTableViewDelegate?
    
    // MARK: - Initialisers
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: .zero, style: .plain)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Setup UI

private extension MediaListRecentSearchTableView {
    
    func setupAppearance() {
        backgroundColor = .mediaBackground
        separatorStyle = .none
        
        register(UITableViewCell.self, forCellReuseIdentifier: Const.recentSearchCellReuseIdentifier)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        delegate = self
        dataSource = self
    }
}

// MARK: - DataSource Methods

extension MediaListRecentSearchTableView: UITableViewDataSource {
    
    func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        interactionDelegate?.getRecentSearches().count ?? .zero
    }
    
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        
        let cellData = interactionDelegate?.getRecentSearches()
        let cell = tableView.dequeueReusableCell(
            withIdentifier: Const.recentSearchCellReuseIdentifier,
            for: indexPath
        )
        
        cell.backgroundColor = .mediaBackground
        cell.textLabel?.text = cellData?[indexPath.row]
        cell.textLabel?.textColor = .white
        cell.selectionStyle = .none
        
        return cell
    }
}

// MARK: - Delegate Methods

extension MediaListRecentSearchTableView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        interactionDelegate?.didTapRecentTerm(at: indexPath.row)
    }
}
