import Foundation

struct ArtistModel: Decodable {
    let results: [Artist]
}

struct Artist: Decodable, Equatable {
    let kind: String
    let name: String
    let link: String
    let genre: String?
    
    private enum CodingKeys: String, CodingKey {
        case kind = "artistType"
        case name = "artistName"
        case link = "artistLinkUrl"
        case genre = "primaryGenreName"
    }
}

private extension Artist {
    
    enum Kind {
        case songArtist
        case movieArtist
        case tvShowArtist
        case podcastArtist
        case other(String)
        
        init(_ kind: String) {
            switch kind {
            case Const.songArtistKind:
                self = .songArtist
            case Const.movieArtistKind:
                self = .movieArtist
            case Const.tvShowArtistKind:
                self = .tvShowArtist
            case Const.podcastArtistKind:
                self = .podcastArtist
            default:
                self = .other(kind)
            }
        }
    }
    
    func compareKind() -> Kind {
        Kind(kind)
    }
}

extension Artist {
    
    func namePlaceholder() -> String {
        isSongArtist() ? Const.productionBy.appending(name) : Const.distributedBy.appending(name)
    }
    
    func moreFromArtistPlaceHolder() -> String {
        isSongArtist() ? Const.moreAlbums.appending(name) : Const.moreBundles.appending(name)
    }
    
    func underlinedLinkText() -> NSAttributedString {
        let text = isSongArtist() ? Const.moreAboutArtist : Const.moreAboutDistributor
        return NSAttributedString.underlinedText(text)
    }
}
