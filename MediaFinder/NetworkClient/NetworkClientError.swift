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
            Const.unknownError
        case .urlSessionError(let error):
            Const.urlSessionErrorDebug.appending(error?.localizedDescription ?? "")
        case .noInternetConnection:
            Const.noInternetConnection
        }
    }
}
