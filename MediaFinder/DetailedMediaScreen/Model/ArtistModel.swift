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

extension Artist {
    
    func isSongArtist() -> Bool {
        kind == Const.artistKind
    }
    
    func namePlaceholder() -> String {
        isSongArtist() ? Const.productionBy.appending(name) : Const.distributedBy.appending(name)
    }
    
    func moreFromArtistPlaceHolder() -> String {
        isSongArtist() ? Const.moreAlbums.appending(name) : Const.moreBundles.appending(name)
    }
    
    func attributedLinkText() -> NSAttributedString {
        let placeholder = isSongArtist() ? Const.moreAboutArtist : Const.moreAboutDistributor
        return NSAttributedString.attributedLinkText(placeholder: placeholder, link: link)
    }
}
