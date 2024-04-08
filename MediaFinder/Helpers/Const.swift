import Foundation

enum Const {
    
    // MARK: - NetworkClientError Constants
    
    static let invalidResponseDebug = "Response Not Match HTTPURLResponse"
    static let urlSessionErrorDebug = "URLSession Error: "
    static let noInternetConnectionDebug = "No Internet Connection"
    
    static let noInternetConnection = "You're Offline\nTurn off Airplane Mode or connect to Wi-Fi."
    static let unknownError = "Unknown Error"
    
    // MARK: - MediaListSearchServiceError Constants
    
    static let invalidRequestDebug = "Invalid Request"
    static let notFoundDebug = "Not Found"
    static let tooManyRequestsDebug = "Too Many Requests"
    static let internalServerErrorDebug = "Internal Server Error"
    static let decodingErrorDebug = "Decoding Error: "
    
    static let notFound = "The request cannot be fulfilled because the resource does not exist."
    static let somethingWentWrong = "Something went wrong. Please, try later."
    
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
