import Foundation

enum State: Equatable {
    case idle
    case loading
    case loaded
    case error(String)
}
