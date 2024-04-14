import Foundation

// MARK: - Protocols

protocol SearchHistoryStorageProtocol: AnyObject {
    var recentSearches: [String] { get }
    func addSearchTerm(_ term: String)
}

final class SearchHistoryStorage: SearchHistoryStorageProtocol {
    
    // MARK: - Static Properties
    
    static let shared = SearchHistoryStorage()
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    private let key = "recentSearches"
    
    // MARK: - Private Initialisers
    
    private init() {}
    
    // MARK: - Properties
    
    var recentSearches: [String] {
        userDefaults.stringArray(forKey: key) ?? []
    }
    
    // MARK: - Methods
    
    func addSearchTerm(_ term: String) {
        var searches = recentSearches
        
        if let index = searches.firstIndex(of: term) {
            searches.remove(at: index)
        }
        
        if searches.count == Const.maxRecentSearches {
            searches.removeLast()
        }
        
        searches.insert(term, at: .zero)
        userDefaults.set(searches, forKey: key)
    }
}
