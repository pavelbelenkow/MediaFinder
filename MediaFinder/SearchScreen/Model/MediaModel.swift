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

private extension Media {
    
    enum Kind {
        case song
        case movie
        case tvEpisode
        case podcast
        case musicVideo
        case other(String)
        
        var ratio: CGFloat {
            switch self {
            case .song, .other: 1.0
            default: 0.665
            }
        }
        
        var linkText: String {
            switch self {
            case .song: Const.listenOnAppleMusic
            case .movie, .tvEpisode: Const.watchOnAppleTV
            case .podcast: Const.listenOnApplePodcasts
            case .musicVideo: Const.watchOnAppleMusic
            default: Const.viewOnWeb
            }
        }
        
        init(_ kind: String) {
            switch kind {
            case Const.songKind:
                self = .song
            case Const.movieKind:
                self = .movie
            case Const.tvEpisodeKind:
                self = .tvEpisode
            case Const.podcastKind:
                self = .podcast
            case Const.musicVideoKind:
                self = .musicVideo
            default:
                self = .other(kind)
            }
        }
    }
    
    func compareKind() -> Kind {
        Kind(kind ?? "")
    }
}

extension Media: Hashable {
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension Media {
    
    func setImageQuality(to size: String) -> String? {
        artwork100?.replacingOccurrences(of: Const.oneHundredSize, with: size)
    }
    
    func artistNamePlaceholder() -> String {
        let kind = compareKind()
        
        switch kind {
        case .tvEpisode:
            return Const.fromSeason.appending(collection ?? "")
        default:
            return Const.createdBy.appending(artist ?? "")
        }
    }
    
    func underlinedLinkText() -> NSAttributedString {
        let text = compareKind().linkText
        return NSAttributedString.underlinedText(text)
    }
    
    func attributedDescription(with spacing: CGFloat = Const.spacingExtraSmall) -> NSAttributedString {
        NSAttributedString.attributedTextWithLineSpacing(text: description ?? "", spacing: spacing)
    }
    
    func imageRatio() -> CGFloat {
        compareKind().ratio
    }
    
    func readableDuration() -> String? {
        duration?.millisecondsToReadableString()
    }
    
    func priceWithCurrency() -> String? {
        guard let price = price ?? collectionPrice else { return nil }
        
        return NumberFormatter
            .currencyFormatter
            .string(from: price as NSNumber)
    }
}
