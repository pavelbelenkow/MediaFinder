import Combine
import XCTest
@testable import MediaFinder

// MARK: - Mock ArtistLookupService

final class ArtistLookupServiceMock: ArtistLookupServiceProtocol {
    
    enum MockError: Error {
        case unexpectedRequest
    }
    
    var stubbedArtist: AnyPublisher<[Artist], Error>?
    var stubbedError: Error?
    
    func fetchArtist(by id: Int) -> AnyPublisher<[Artist], Error> {
        if let stubbedArtist {
            return stubbedArtist
        } else if let stubbedError {
            return Fail(error: stubbedError)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: MockError.unexpectedRequest)
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - ArtistLookupService Tests

final class ArtistLookupServiceTests: XCTestCase {
    
    var sut: ArtistLookupServiceProtocol!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = ArtistLookupServiceMock()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testFetchArtistSuccess() {
        
        // Given
        let expectedArtist: [Artist] = [
            Artist(kind: "Movie Artist", name: "Christopher Nolan", link: "", genre: nil)
        ]
        
        (sut as! ArtistLookupServiceMock).stubbedArtist = Just(expectedArtist)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // When
        let publisher = sut.fetchArtist(by: 1)
        let expectation = self.expectation(description: "Fetch Artist List Expectation")
        var receivedArtist: [Artist]?
        var receivedError: Error?
        let cancellable = publisher
            .sink { completion in
                
                switch completion {
                case .finished: break
                case .failure(let error):
                    receivedError = error
                }
                
                expectation.fulfill()
            } receiveValue: { artist in
                receivedArtist = artist
            }
        
        waitForExpectations(timeout: 1.0)
        cancellable.cancel()
        
        // Then
        XCTAssertNotNil(receivedArtist)
        XCTAssertEqual(receivedArtist, expectedArtist)
        XCTAssertNil(receivedError)
    }
    
    func testFetchArtistFailure() {
        
        // Given
        let expectedError = URLError(.notConnectedToInternet)
        (sut as! ArtistLookupServiceMock).stubbedError = expectedError
        
        // When
        let publisher = sut.fetchArtist(by: 1)
        let expectation = expectation(description: "Fetch Artist List Expectation")
        var receivedError: Error?
        let cancellable = publisher.sink { completion in
            
            if case .failure(let error) = completion {
                receivedError = error
            }
            
            expectation.fulfill()
        } receiveValue: { _ in }
        
        waitForExpectations(timeout: 1.0)
        cancellable.cancel()
        
        // Then
        XCTAssertNotNil(receivedError)
        XCTAssertEqual(receivedError as? URLError, expectedError)
    }
}
