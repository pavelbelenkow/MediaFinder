import Combine
import XCTest
@testable import MediaFinder

// MARK: - Mock NetworkClient

final class NetworkClientMock: NetworkClient {
    
    enum MockError: Error {
        case unexpectedRequest
    }
    
    var stubbedResponse: (Data, HTTPURLResponse)?
    var stubbedError: Error?
    
    func publisher(request: URLRequest) -> AnyPublisher<(Data, HTTPURLResponse), any Error> {
        
        if let stubbedResponse {
            return Result.Publisher(stubbedResponse)
                .eraseToAnyPublisher()
        } else if let stubbedError {
            return Fail(error: stubbedError)
                .eraseToAnyPublisher()
        } else {
            return Fail(error: MockError.unexpectedRequest)
                .eraseToAnyPublisher()
        }
    }
}

// MARK: - NetworkClient Tests

final class NetworkClientTests: XCTestCase {
    
    var sut: NetworkClient!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = NetworkClientMock()
    }
    
    override func tearDownWithError() throws {
        sut = nil
        try super.tearDownWithError()
    }
    
    func testPublisherSuccess() {
        
        // Given
        let url = URL(string: "https://example.com")!
        let expectedData = Data()
        let expectedResponse = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        
        (sut as! NetworkClientMock).stubbedResponse = (expectedData, expectedResponse)
        
        let request = URLRequest(url: url)
        
        // When
        let publisher = sut.publisher(request: request)
        var receivedData: Data?
        var receivedResponse: HTTPURLResponse?
        var receivedError: Error?
        let expectation = self.expectation(description: "Network call expectation")
        let cancellable = publisher
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    receivedError = error
                }
                
                expectation.fulfill()
            } receiveValue: { (data, response) in
                receivedData = data
                receivedResponse = response
            }
        
        waitForExpectations(timeout: 1.0)
        cancellable.cancel()
        
        // Then
        XCTAssertNotNil(receivedData)
        XCTAssertEqual(receivedData, expectedData)
        XCTAssertEqual(receivedResponse, expectedResponse)
        XCTAssertNil(receivedError)
    }
    
    func testPublisherFailure() {
        
        // Given
        let url = URL(string: "https://example.com")!
        let expectedError = URLError(.notConnectedToInternet)
        (sut as! NetworkClientMock).stubbedError = expectedError
        
        let request = URLRequest(url: url)
        
        // When
        let publisher = sut.publisher(request: request)
        var receivedError: Error?
        let expectation = self.expectation(description: "Network call expectation")
        let cancellable = publisher
            .sink { completion in
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
