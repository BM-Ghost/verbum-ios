import Foundation

/// Sealed-state equivalent for async operations.
enum VerbumResult<T> {
    case loading
    case success(T)
    case error(String)
}
