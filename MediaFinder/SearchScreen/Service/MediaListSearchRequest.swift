import Foundation

// MARK: - MediaListSearch Request

struct MediaListSearchRequest: NetworkRequest {
    let term: String
    var entity: EntityType
    var limit: Int
    var page: Int
    
    var path: String { Const.searchPath }
    var parameters: [(String, Any)] {
        let offset = page * limit
        
        var params: [(String, Any)] = []
        
        params.append((Const.termKey, term))
        if entity != .all {
            params.append((Const.entityKey, entity))
        }
        params.append((Const.limitKey, limit))
        params.append((Const.offsetKey, offset))
        
        return params
    }
}
