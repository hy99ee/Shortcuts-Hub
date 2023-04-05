import Firebase

protocol FetchedResponceType {
    associatedtype DataType
    var query: DataType { get }
    var count: Int { get }
}

struct FetchedSectionResponce: FetchedResponceType {
    let query: [Query]
    let count: Int
}

struct FetchedResponce: FetchedResponceType {
    let query: Query
    let count: Int
}

struct MockFetchedResponce: FetchedResponceType {
    struct MockQuery {
        let data: String
    }

    let query: MockQuery
    let count: Int
}
