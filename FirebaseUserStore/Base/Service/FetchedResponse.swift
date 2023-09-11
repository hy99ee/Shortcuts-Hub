import Firebase

protocol FetchedResponseType {
    associatedtype DataType
    var query: DataType { get }
    var count: Int { get }
}

struct FetchedSectionResponce: FetchedResponseType {
    let query: [Query]
    let count: Int
}

struct FetchedResponse: FetchedResponseType {
    let query: Query
    let count: Int
}

struct MockFetchedResponce: FetchedResponseType {
    struct MockQuery {
        let data: String
    }

    let query: MockQuery
    let count: Int
}
