import Combine
import XCTest
@testable import MediaFinder

// MARK: - DetailedMediaViewModel Tests

final class DetailedMediaViewModelTests: XCTestCase {
    
    let mediaModelMock = Media(kind: "song", artistId: 123, artist: nil, name: "Test Song", collectionArtistId: nil,
                               trackView: nil, artwork60: nil, artwork100: nil, price: nil, releaseDate: nil,
                               description: nil, duration: nil)
    
    var serviceMock: ArtistLookupServiceProtocol!
    var sut: (any DetailedMediaViewModelProtocol)?
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceMock = ArtistLookupServiceMock()
        sut = DetailedMediaViewModel(mediaModel: mediaModelMock, artistLookupService: serviceMock)
        cancellables = []
    }
    
    override func tearDownWithError() throws {
        cancellables.forEach { $0.cancel() }
        serviceMock = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testFetchArtistSuccess() {
        
        // Given
        let expectedArtist = [Artist(kind: "", name: "Test Artist", link: "", genre: nil)]
        (serviceMock as! ArtistLookupServiceMock).stubbedArtist = Just(expectedArtist)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        // When
        sut?.fetchArtist()
        
        // Then
        let expectation = expectation(description: "Fetch Artist")
        var receivedState: State?
        var receivedArtist: [Artist]?
        
        sut?.stateSubject.sink { state in
            receivedState = state
            
            if state == .loaded {
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        
        sut?.artistSubject.sink { artist in
            receivedArtist = artist
        }.store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(receivedState, .loaded)
        XCTAssertEqual(receivedArtist?.first, expectedArtist.first)
    }
    
    func testFetchArtistFailure() {
        
        // Given
        let expectedError = NSError(domain: "TestErrorDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test Error"])
        (serviceMock as! ArtistLookupServiceMock).stubbedError = expectedError
        
        // When
        sut?.fetchArtist()
        
        // Then
        let expectation = expectation(description: "Fetch Artist")
        var receivedState: State?
        var receivedError: String?
        
        sut?.stateSubject.sink { state in
            receivedState = state
            
            if case .error(let error) = state {
                receivedError = error
            }
            
            expectation.fulfill()
        }.store(in: &cancellables)
        
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(receivedState, sut?.stateSubject.value)
        XCTAssertEqual(receivedError, expectedError.localizedDescription)
    }
}
