import Foundation
import Combine

// MARK: - NetworkClient Protocol

protocol NetworkClient {
    func publisher(request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error>
}

// MARK: - NetworkClient Methods

extension URLSession: NetworkClient {
    
    func publisher(request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), Error> {
        
        return dataTaskPublisher(for: request)
            .tryMap { result in
                guard let httpResponse = result.response as? HTTPURLResponse else {
                    throw NetworkClientError.invalidResponse
                }
                
                return (result.data, httpResponse)
            }
            .mapError { error in
                self.mapUrlError(error)
            }
            .eraseToAnyPublisher()
    }
    
    private func mapUrlError(_ error: Error) -> Error {
        
        guard
            let urlError = error as? URLError,
            urlError.code == .notConnectedToInternet
        else {
            return NetworkClientError.urlSessionError(error as? URLError)
        }
        
        return NetworkClientError.noInternetConnection
    }
}
