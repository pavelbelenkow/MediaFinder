import Foundation

enum Const {
    
    // MARK: - NetworkClientError Constants
    
    static let invalidResponseDebug = "Response Not Match HTTPURLResponse"
    static let urlSessionErrorDebug = "URLSession Error: "
    static let noInternetConnectionDebug = "No Internet Connection"
    
    static let noInternetConnection = "You're Offline"
    static let unknownError = "Unknown Error"
    
    // MARK: - URL Components
    
    static let baseEndpoint = "https://itunes.apple.com"
    static let searchPath = "/search"
    static let termKey = "term"
    static let entityKey = "entity"
    static let limitKey = "limit"
    static let offsetKey = "offset"
    static let defaultLimit = 30
    static let offset = 0
}
