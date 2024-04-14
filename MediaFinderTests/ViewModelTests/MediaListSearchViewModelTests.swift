import Combine
import XCTest
@testable import MediaFinder

// MARK: - Mock SearchHistoryStorage

final class SearchHistoryStorageMock: SearchHistoryStorageProtocol {
    
    var isAddSearchTermCalled = false
    var recentSearches: [String] = []
    
    func addSearchTerm(_ term: String) {
        isAddSearchTermCalled = true
        recentSearches.append(term)
    }
}

// MARK: - MediaListSearchViewModel Tests

final class MediaListSearchViewModelTests: XCTestCase {
    
    var serviceMock: MediaListSearchServiceProtocol!
    var storageMock: SearchHistoryStorageProtocol!
    var sut: (any MediaListSearchViewModelProtocol)?
    var cancellables: Set<AnyCancellable>!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        serviceMock = MediaListSearchServiceMock()
        storageMock = SearchHistoryStorageMock()
        sut = MediaListSearchViewModel(service: serviceMock, storage: storageMock)
        cancellables = []
    }
    
    override func tearDownWithError() throws {
        cancellables.forEach { $0.cancel() }
        serviceMock = nil
        storageMock = nil
        sut = nil
        try super.tearDownWithError()
    }
    
    func testFetchSearchListSuccess() {
        
        // Given
        let expectedMediaList = [
            Media(kind: "feature-movie", artistId: nil, artist: nil, name: "Emily", collectionArtistId: nil, trackView: nil, artwork60: nil, artwork100: nil, price: nil, releaseDate: nil, description: nil, duration: nil),
            Media(kind: "song", artistId: nil, artist: nil, name: "Vampire", collectionArtistId: nil, trackView: nil, artwork60: nil, artwork100: nil, price: nil, releaseDate: nil, description: nil, duration: nil),
        ]
        (serviceMock as! MediaListSearchServiceMock).stubbedMediaList = Just(expectedMediaList)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
        
        let expectation = expectation(description: "Fetch Media Search List")
        
        // When
        sut?.fetchSearchList()
        
        // Then
        var receivedState: State?
        var receivedMediaList: [Media]?
        
        
        sut?.stateSubject.sink { state in
            receivedState = state
        }.store(in: &cancellables)
        
        
        sut?.searchListSubject.sink { mediaList in
            receivedMediaList = mediaList
        }.store(in: &cancellables)
        
        expectation.fulfill()
        waitForExpectations(timeout: 1.0)
        
        XCTAssertEqual(receivedState, .loaded)
        XCTAssertEqual(receivedMediaList, expectedMediaList)
        XCTAssertTrue((serviceMock as! MediaListSearchServiceMock).isFetchMediaListCalled)
    }
    
    func testFetchSearchListFailure() {
        
        // Given
        let expectedError = NSError(domain: "TestErrorDomain", code: 123, userInfo: [NSLocalizedDescriptionKey: "Test Error"])
        (serviceMock as! MediaListSearchServiceMock).stubbedError = expectedError
        
        let expectation = expectation(description: "Fetch Media Search List")
        
        // When
        sut?.fetchSearchList()
        
        // Then
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
        XCTAssertTrue((serviceMock as! MediaListSearchServiceMock).isFetchMediaListCalled)
    }
    
    func testFetchSearchListForMediaType() {
        
        // Given
        let entityTypes: [EntityType] = [.all, .movie, .song]
        let expectedPlaceholders = [Const.songsAndMoviesPlaceholder, Const.moviesPlaceholder, Const.songsPlaceholder]
        
        for index in 0..<entityTypes.count {
            
            // When
            sut?.fetchSearchListForMediaType(by: index)
            
            // Then
            XCTAssertEqual((sut?.searchBarPlaceholderSubject.value), expectedPlaceholders[index])
        }
    }
    
    func testSetSearchTerm() {
        
        // Given
        let searchTerm = "Test Search Term"
        
        // When
        sut?.setSearchTerm(for: searchTerm)
        
        // Then
        XCTAssertTrue((storageMock as! SearchHistoryStorageMock).isAddSearchTermCalled)
        XCTAssertEqual((sut?.recentSearchesSubject.value.first), searchTerm)
        XCTAssertTrue((serviceMock as! MediaListSearchServiceMock).isFetchMediaListCalled)
    }
    
    func testSetResultsLimit() {
        
        // Given
        let newLimit = 50
        
        // When
        sut?.setResultsLimit(for: newLimit)
        
        // Then
        XCTAssertEqual((sut?.limitSubject.value), newLimit)
    }
    
    func testFilterSuggestions() {
        
        // Given
        let searchText = "Test Search Term"
        let filteredSuggestions = (storageMock as! SearchHistoryStorageMock).recentSearches.filter {
            $0.localizedCaseInsensitiveContains(searchText)
        }
        
        // When
        sut?.filterSuggestions(for: searchText)
        
        // Then
        XCTAssertEqual((sut?.recentSearchesSubject.value), filteredSuggestions)
    }
    
    func testDidSelectRecentSearch() {
        
        // Given
        let selectedIndex = 2
        let selectedSearchTerm = "Selected Search Term"
        let recentSearches = ["Recent Search 1", "Recent Search 2", selectedSearchTerm]
        sut?.recentSearchesSubject.send(recentSearches)
        
        // When
        sut?.didSelectRecentSearch(at: selectedIndex)
        
        // Then
        XCTAssertEqual((sut?.searchBarTextSubject.value), selectedSearchTerm)
    }
    
    func testDidSelectMedia() {
        
        // Given
        let selectedIndex = 1
        let selectedMediaItem = Media(kind: "song", artistId: nil, artist: nil, name: "Test Song", collectionArtistId: nil, trackView: nil, artwork60: nil, artwork100: nil, price: nil, releaseDate: nil, description: nil, duration: nil)
        let mediaList = [
            Media(kind: "feature-movie", artistId: nil, artist: nil, name: "Test Movie", collectionArtistId: nil, trackView: nil, artwork60: nil, artwork100: nil, price: nil, releaseDate: nil, description: nil, duration: nil),
            selectedMediaItem
        ]
        sut?.searchListSubject.send(mediaList)
        
        // When
        sut?.didSelectMedia(at: selectedIndex)
        
        // Then
        XCTAssertEqual((sut?.selectedMediaSubject.value), selectedMediaItem)
    }
}
