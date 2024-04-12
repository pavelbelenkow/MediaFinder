import Foundation

// MARK: - ArtistMapper

struct ArtistMapper {
    
    // MARK: - Private Properties
    
    private static let decoder = JSONDecoder()
    
    // MARK: - Methods
    
    static func map(data: Data, response: HTTPURLResponse) throws -> [Artist] {
        
        switch response.statusCode {
        case 200:
            do {
                let mediaModel = try decoder.decode(ArtistModel.self, from: data)
                return mediaModel.results
            } catch {
                try mapDecodingError(error)
            }
        case 204:
            return []
        case 400:
            throw MediaListSearchServiceError.invalidRequest
        case 404:
            throw MediaListSearchServiceError.notFound
        case 429:
            throw MediaListSearchServiceError.tooManyRequests
        case 500:
            throw MediaListSearchServiceError.internalServerError
        default:
            throw MediaListSearchServiceError.unknown
        }
        
        return []
    }
}

// MARK: - Private Methods

private extension ArtistMapper {
    
    static func mapDecodingError(_ error: Error) throws {
        
        if let decodingError = error as? DecodingError {
            
            switch decodingError {
            case .dataCorrupted, .keyNotFound, .typeMismatch, .valueNotFound:
                throw MediaListSearchServiceError.decodingError(decodingError)
            @unknown default:
                throw MediaListSearchServiceError.unknown
            }
        } else {
            throw MediaListSearchServiceError.unknown
        }
    }
}
