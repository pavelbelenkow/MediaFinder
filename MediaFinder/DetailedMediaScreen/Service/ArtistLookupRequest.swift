import Foundation

// MARK: - ArtistLookup Request

struct ArtistLookupRequest: NetworkRequest {
    let id: Int
    var path: String { Const.lookupPath }
    var parameters: [(String, Any)] { [(Const.idKey, id)] }
}
