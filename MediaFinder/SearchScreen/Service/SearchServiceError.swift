import Foundation

// MARK: - SearchService Error

enum SearchServiceError: Error {
    case invalidRequest
    case forbidden
    case notFound
    case tooManyRequests
    case internalServerError
    case decodingError(Error)
    case unknown
}

// MARK: - Localized Description of SearchServiceError

extension SearchServiceError: LocalizedError {
    
    var errorDescription: String? {
        
        switch self {
        case .invalidRequest, .forbidden, .tooManyRequests, .internalServerError, .unknown:
            Const.somethingWentWrong
        case .notFound:
            Const.notFound
        case .decodingError(let decodingError):
            decodingError.localizedDescription
        }
    }
}
