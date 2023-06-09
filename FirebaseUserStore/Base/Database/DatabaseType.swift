import Combine

protocol DatabaseType {
    associatedtype Mutation: Equatable

    var mutation: Mutation? { get }

    func updateUserData(with mutation: Mutation) -> AnyPublisher<Void, SessionServiceError>
}
