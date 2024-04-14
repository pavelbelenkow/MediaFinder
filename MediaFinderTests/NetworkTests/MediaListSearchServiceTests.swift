import Combine
import XCTest
@testable import MediaFinder

// MARK: - Mock MediaListSearchService

final class MediaListSearchServiceMock: MediaListSearchServiceProtocol {
    
    enum MockError: Error {
        case unexpectedRequest
    }
    
    var stubbedMediaList: AnyPublisher<[Media], Error>?
    var stubbedError: Error?
    var isFetchMediaListCalled = false
    
    func fetchMediaList(
        for term: String,
        type: MediaFinder.EntityType,
        limit: Int,
        page: Int
    ) -> AnyPublisher<[MediaFinder.Media], Error> {
        isFetchMediaListCalled = true
        
        if let stubbedMediaList {
            return stubbedMediaList
        } else if let stubbedError {
            return Fail(error: stubbedError)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: MockError.unexpectedRequest)
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - MediaListSearchService Tests

final class MediaListSearchServiceTests: XCTestCase {
    
    var sut: MediaListSearchServiceProtocol!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = MediaListSearchServiceMock()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testFetchMediaListSuccess() {
        
        // Given
        let expectedMediaList: [Media] = [
            Media(kind: nil, artistId: nil, artist: nil, name: nil, collectionArtistId: nil, trackView: nil, artwork60: nil, artwork100: nil, price: nil, releaseDate: nil, description: nil, duration: nil)
        ]
        
        (sut as! MediaListSearchServiceMock).stubbedMediaList = Just(expectedMediaList)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // When
        let publisher = sut.fetchMediaList(for: "term", type: .movie, limit: 30, page: 1)
        let expectation = self.expectation(description: "Fetch Media List Expectation")
        var receivedMediaList: [Media]?
        var receivedError: Error?
        let cancellable = publisher
            .sink { completion in
                
                switch completion {
                case .finished: break
                case .failure(let error):
                    receivedError = error
                }
                
                expectation.fulfill()
            } receiveValue: { mediaList in
                receivedMediaList = mediaList
            }
        
        waitForExpectations(timeout: 1.0)
        cancellable.cancel()
        
        // Then
        XCTAssertNotNil(receivedMediaList)
        XCTAssertEqual(receivedMediaList, expectedMediaList)
        XCTAssertNil(receivedError)
    }
    
    func testFetchMediaListFailure() {
        
        // Given
        let expectedError = URLError(.notConnectedToInternet)
        (sut as! MediaListSearchServiceMock).stubbedError = expectedError
        
        // When
        let publisher = sut.fetchMediaList(for: "term", type: .movie, limit: 30, page: 1)
        let expectation = expectation(description: "Fetch Media List Expectation")
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
