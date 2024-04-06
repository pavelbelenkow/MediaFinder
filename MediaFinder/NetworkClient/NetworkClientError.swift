import Foundation

// MARK: - NetworkClientError

enum NetworkClientError: Error {
    case invalidResponse
    case urlSessionError(URLError?)
    case noInternetConnection
}

// MARK: - Localized Description of NetworkClientError

extension NetworkClientError: LocalizedError {
    
    var errorDescription: String? {
        
        switch self {
        case .invalidResponse:
            Const.invalidResponseDebug
        case .urlSessionError(let error):
            Const.urlSessionErrorDebug.appending(error.debugDescription)
        case .noInternetConnection:
            Const.noInternetConnectionDebug
        }
    }
    
    var localizedDescription: String {
        
        switch self {
        case .noInternetConnection:
            Const.noInternetConnection
        case .invalidResponse, .urlSessionError:
            Const.unknownError
        }
    }
}
