import Foundation

// MARK: - MediaListSearchService Error

enum MediaListSearchServiceError: Error {
    case invalidRequest
    case notFound
    case tooManyRequests
    case internalServerError
    case decodingError(Error)
    case unknown
}

// MARK: - Localized Description of MediaListSearchServiceError

extension MediaListSearchServiceError: LocalizedError {
    
    var errorDescription: String? {
        
        switch self {
        case .invalidRequest:
            Const.invalidRequestDebug
        case .notFound:
            Const.notFoundDebug
        case .tooManyRequests:
            Const.tooManyRequestsDebug
        case .internalServerError:
            Const.internalServerErrorDebug
        case .decodingError(let decodingError):
            Const.decodingErrorDebug.appending(decodingError.localizedDescription)
        case .unknown:
            Const.unknownError
        }
    }
    
    var localizedDescription: String {
        
        switch self {
        case .invalidRequest, .tooManyRequests, .internalServerError, .unknown:
            Const.somethingWentWrong
        case .notFound:
            Const.notFound
        case .decodingError(let decodingError):
            decodingError.localizedDescription
        }
    }
}
