import Foundation
import Combine

// MARK: - Protocols

protocol MediaListSearchServiceProtocol {
    func fetchMediaList(for term: String, type: EntityType, limit: Int, page: Int) -> AnyPublisher<[Media], Error>
}

final class MediaListSearchService {
    
    // MARK: - Private Properties
    
    private let networkClient: NetworkClient
    
    // MARK: - Initialisers
    
    init(networkClient: NetworkClient = URLSession.shared) {
        self.networkClient = networkClient
    }
}

// MARK: - Private Methods

private extension MediaListSearchService {
    
    func create(request: NetworkRequest) -> URLRequest? {
        
        guard let url = request.makeURL() else {
            assertionFailure("Invalid URL")
            return nil
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.httpMethod.rawValue
        
        return urlRequest
    }
}

// MARK: - MediaListSearchServiceProtocol Methods

extension MediaListSearchService: MediaListSearchServiceProtocol {
    
    func fetchMediaList(
        for term: String,
        type: EntityType,
        limit: Int,
        page: Int
    ) -> AnyPublisher<[Media], Error> {
        
        let request = MediaListSearchRequest(
            term: term,
            entity: type,
            limit: limit,
            page: page
        )
        
        guard let urlRequest = create(request: request) else {
            return Fail(error: MediaListSearchServiceError.invalidRequest).eraseToAnyPublisher()
        }
        
        return networkClient
            .publisher(request: urlRequest)
            .tryMap(MediaListMapper.map)
            .eraseToAnyPublisher()
    }
}
