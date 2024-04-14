import Foundation

enum Const {
    
    // MARK: - NetworkClientError Constants
    
    static let invalidResponseDebug = "Response Not Match HTTPURLResponse"
    static let urlSessionErrorDebug = "URLSession Error: "
    static let noInternetConnectionDebug = "No Internet Connection"
    
    static let noInternetConnection = "You're Offline.\nTurn off Airplane Mode or connect to Wi-Fi."
    static let unknownError = "Unknown Error"
    
    // MARK: - SearchServiceError Constants
    
    static let invalidRequestDebug = "Invalid Request"
    static let notFoundDebug = "Not Found"
    static let tooManyRequestsDebug = "Too Many Requests"
    static let internalServerErrorDebug = "Internal Server Error"
    static let decodingErrorDebug = "Decoding Error: "
    
    static let notFound = "The request cannot be fulfilled because the resource does not exist."
    static let somethingWentWrong = "Something went wrong. Please, try later."
    
    // MARK: - URL Components
    
    static let baseEndpoint = "https://itunes.apple.com"
    static let searchPath = "/search"
    static let lookupPath = "/lookup"
    static let idKey = "id"
    static let termKey = "term"
    static let entityKey = "entity"
    static let limitKey = "limit"
    static let offsetKey = "offset"
    static let offset = 0
    
    // MARK: - Model Constants
    
    static let songKind = "song"
    static let movieKind = "feature-movie"
    static let artistKind = "Artist"
    static let listenInAppleMusic = "Listen in Apple Music"
    static let watchOnAppleTV = "Watch on Apple TV"
    static let productionBy = "Production by "
    static let distributedBy = "Distributed by "
    static let moreAboutArtist = "More about the artist"
    static let moreAboutDistributor = "More about the distributor"
    
    // MARK: - MediaListSearch Screen Constants
    
    static let navigationBarTitle = "Search"
    static let songsAndMoviesPlaceholder = "Songs and Movies"
    static let songsPlaceholder = "Songs"
    static let moviesPlaceholder = "Movies"
    static let mediaTypeButtonTitles = ["All", "Movies", "Songs"]
    static let collectionViewReuseIdentifier = "mediaCell"
    static let tableViewReuseIdentifier = "recentSearchCell"
    static let noResultsTitle = "No Results"
    static let noResultsDescription = "Try a new search."
    static let loadingDescription = "Loading"
    static let repeatButtonTitle = "Try Again"
    static let limitIcon = "line.horizontal.3.decrease.circle"
    
    static let limitTen = 10
    static let limitThirty = 30
    static let limitFifty = 50
    static let maxRecentSearches = 5
    static let collectionViewCellCount = 2
    static let spacingThirty: CGFloat = 30
    static let spacingExtraSmall: CGFloat = 4
    static let spacingSmall: CGFloat = 8
    static let spacingMedium: CGFloat = 16
    static let spacingLarge: CGFloat = 60
    static let spacingOneHundred: CGFloat = 100
    static let collectionViewCellHeight: CGFloat = 200
    static let collectionCellCornerRadius: CGFloat = 15
    static let mediaImageViewHeight: CGFloat = 80
    static let repeatButtonBorderWidth: CGFloat = 1
    static let repeatButtonCornerRadius: CGFloat = 10
    
    // MARK: - DetailedMedia Screen Constants
    
    static let createdBy = "by\n"
    static let aboutArtist = "About "
    static let artistGenre = "Genre: "
}
