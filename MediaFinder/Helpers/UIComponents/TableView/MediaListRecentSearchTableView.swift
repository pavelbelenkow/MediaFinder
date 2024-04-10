import UIKit

// MARK: - Delegates

protocol MediaListRecentSearchTableViewDelegate: AnyObject {
    func getRecentSearches() -> [String]
    func didTapRecentTerm(for index: Int)
}

final class MediaListRecentSearchTableView: UITableView {
    
    // MARK: - Properties
    
    weak var interactionDelegate: MediaListRecentSearchTableViewDelegate?
    
    // MARK: - Initialisers
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: .zero, style: .plain)
        
        backgroundColor = .mediaBackground
        separatorStyle = .none
        
        delegate = self
        dataSource = self
        
        register(UITableViewCell.self, forCellReuseIdentifier: Const.tableViewReuseIdentifier)
        
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
            withIdentifier: Const.tableViewReuseIdentifier,
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
        let cellData = interactionDelegate?.getRecentSearches()
        guard let selectedSearch = cellData?[indexPath.row] else { return }
        print("Selected search: \(selectedSearch)")
        interactionDelegate?.didTapRecentTerm(for: indexPath.row)
    }
}
