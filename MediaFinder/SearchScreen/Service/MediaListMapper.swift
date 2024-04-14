import Foundation

// MARK: - MediaListMapper

struct MediaListMapper {
    
    // MARK: - Private Properties
    
    private static let decoder = JSONDecoder()
    
    // MARK: - Methods
    
    static func map(data: Data, response: HTTPURLResponse) throws -> [Media] {
        
        switch response.statusCode {
        case 200:
            do {
                let mediaModel = try decoder.decode(MediaModel.self, from: data)
                let songsAndMovies = mediaModel.results.filter { $0.isSong() || $0.isMovie() }
                return songsAndMovies
            } catch {
                try mapDecodingError(error)
            }
        case 204:
            return []
        case 400:
            throw SearchServiceError.invalidRequest
        case 403:
            throw SearchServiceError.forbidden
        case 404:
            throw SearchServiceError.notFound
        case 429:
            throw SearchServiceError.tooManyRequests
        case 500:
            throw SearchServiceError.internalServerError
        default:
            throw SearchServiceError.unknown
        }
        
        return []
    }
}

// MARK: - Private Methods

private extension MediaListMapper {
    
    static func mapDecodingError(_ error: Error) throws {
        
        if let decodingError = error as? DecodingError {
            
            switch decodingError {
            case .dataCorrupted, .keyNotFound, .typeMismatch, .valueNotFound:
                throw SearchServiceError.decodingError(decodingError)
            @unknown default:
                throw SearchServiceError.decodingError(error)
            }
        } else {
            throw SearchServiceError.decodingError(error)
        }
    }
}
