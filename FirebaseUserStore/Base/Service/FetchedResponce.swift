import Firebase

protocol FetchedResponceType {
    associatedtype DataType
    var query: DataType { get }
    var count: Int { get }
}

struct FetchedResponce: FetchedResponceType {
    let query: Query
    let count: Int
}

struct MockFetchedResponce: FetchedResponceType {
    struct MockQuery {
        let data: String
        let local: Set<UUID>
    }

    let query: MockQuery
    let count: Int
}
