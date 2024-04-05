import Foundation

struct MediaModel: Decodable {
    let resultCount: Int
    let results: [Media]
}

struct Media: Decodable {
    let kind: String?
    let artistId: Int?
    let artist: String?
    let name: String?
    let artistView: String?
    let trackView: String?
    let artwork60: String?
    let artwork100: String?
    let price: Double?
    let releaseDate: String?
    let description: String?
    let duration: Int?
    
    private enum CodingKeys: String, CodingKey {
        case kind
        case artistId
        case artist = "artistName"
        case name = "trackName"
        case artistView = "artistViewUrl"
        case trackView = "trackViewUrl"
        case artwork60 = "artworkUrl60"
        case artwork100 = "artworkUrl100"
        case price = "trackPrice"
        case releaseDate
        case description = "shortDescription"
        case duration = "trackTimeMillis"
    }
}
