import Foundation
import Combine

// MARK: - Protocols

protocol ArtistLookupServiceProtocol {
    func fetchArtist(by id: Int) -> AnyPublisher<[Artist], Error>
    func fetchArtistCollection(by id: Int) -> AnyPublisher<[Media], Error>
}

final class ArtistLookupService {
    
    // MARK: - Private Properties
    
    private let networkClient: NetworkClient
    
    // MARK: - Initialisers
    
    init(networkClient: NetworkClient = URLSession.shared) {
        self.networkClient = networkClient
    }
}

// MARK: - Private Methods

private extension ArtistLookupService {
    
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

// MARK: - ArtistLookupServiceProtocol Methods

extension ArtistLookupService: ArtistLookupServiceProtocol {
    
    func fetchArtist(by id: Int) -> AnyPublisher<[Artist], Error> {
        
        let request = ArtistLookupRequest(id: id)
        
        guard let urlRequest = create(request: request) else {
            return Fail(error: SearchServiceError.invalidRequest).eraseToAnyPublisher()
        }
        
        return networkClient
            .publisher(request: urlRequest)
            .tryMap(ArtistMapper.map)
            .eraseToAnyPublisher()
    }
    
    func fetchArtistCollection(by id: Int) -> AnyPublisher<[Media], Error> {
        
        let request = ArtistCollectionLookupRequest(id: id)
        
        guard let urlRequest = create(request: request) else {
            return Fail(error: SearchServiceError.invalidRequest).eraseToAnyPublisher()
        }
        
        return networkClient
            .publisher(request: urlRequest)
            .tryMap(ArtistCollectionMapper.map)
            .eraseToAnyPublisher()
    }
}
