import Foundation

// MARK: - MediaListSearch Request

struct MediaListSearchRequest: NetworkRequest {
    let term: String
    var entity: EntityType
    var limit: Int
    var page: Int
    
    var path: String { Const.searchPath }
    var parameters: [String: Any] {
        let offset = page * limit
        
        var params: [String: Any] = [:]
        
        params[Const.termKey] = term
        if entity != .all {
            params[Const.entityKey] = entity
        }
        params[Const.limitKey] = limit
        params[Const.offsetKey] = offset
        
        return params
    }
}
