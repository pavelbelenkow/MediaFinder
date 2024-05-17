import Foundation

struct MediaModel: Decodable {
    let resultCount: Int
    let results: [Media]
}

struct Media: Decodable {
    let id = UUID()
    let kind: String?
    let artistId: Int?
    let artist: String?
    let collection: String?
    let name: String?
    let collectionArtistId: Int?
    let collectionView: String?
    let trackView: String?
    let artwork60: String?
    let artwork100: String?
    let collectionPrice: Double?
    let price: Double?
    let releaseDate: String?
    let genre: String?
    let description: String?
    let duration: Int?
    
    private enum CodingKeys: String, CodingKey {
        case kind
        case artistId
        case artist = "artistName"
        case collection = "collectionName"
        case name = "trackName"
        case collectionArtistId
        case collectionView = "collectionViewUrl"
        case trackView = "trackViewUrl"
        case artwork60 = "artworkUrl60"
        case artwork100 = "artworkUrl100"
        case collectionPrice
        case price = "trackPrice"
        case releaseDate
        case genre = "primaryGenreName"
        case description = "longDescription"
        case duration = "trackTimeMillis"
    }
}

extension Media: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Media {
    
    func isSong() -> Bool {
        kind == Const.songKind
    }
    
    func isMovie() -> Bool {
        kind == Const.movieKind
    }
    
    func setImageQuality(to size: String) -> String? {
        artwork100?.replacingOccurrences(of: Const.oneHundredSize, with: size)
    }
    
    func attributedLinkText() -> NSAttributedString {
        let placeholder = isSong() ? Const.listenInAppleMusic : Const.watchOnAppleTV
        return NSAttributedString.attributedLinkText(placeholder: placeholder, link: trackView ?? "")
    }
}
