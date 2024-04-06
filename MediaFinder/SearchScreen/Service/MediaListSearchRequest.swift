import Foundation

// MARK: - MediaListSearch Request

struct MediaListSearchRequest: NetworkRequest {
    let term: String
    var entity: EntityType = .all
    var limit: Int = Const.defaultLimit
    var page: Int = .zero
    
    var path: String { Const.searchPath }
    var parameters: [String: Any] {
        let offset = page * limit
        
        var params: [String: Any] = [:]
        
        params[Const.termKey] = term
        params[Const.entityKey] = entity
        params[Const.limitKey] = limit
        params[Const.offsetKey] = offset
        
        return params
    }
}
