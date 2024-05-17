import Foundation

// MARK: - ArtistCollectionLookup Request

struct ArtistCollectionLookupRequest: NetworkRequest {
    let id: Int
    var path: String { Const.lookupPath }
    var parameters: [(String, Any)] {
        [
            (Const.idKey, id),
            (Const.entityKey, Const.albumKind)
        ]
    }
}
