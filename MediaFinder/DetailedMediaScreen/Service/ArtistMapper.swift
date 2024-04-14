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
            throw SearchServiceError.invalidRequest
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

private extension ArtistMapper {
    
    static func mapDecodingError(_ error: Error) throws {
        
        if let decodingError = error as? DecodingError {
            
            switch decodingError {
            case .dataCorrupted, .keyNotFound, .typeMismatch, .valueNotFound:
                throw SearchServiceError.decodingError(decodingError)
            @unknown default:
                throw SearchServiceError.unknown
            }
        } else {
            throw SearchServiceError.unknown
        }
    }
}
