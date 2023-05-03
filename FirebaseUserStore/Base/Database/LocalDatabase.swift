import Combine
import SwiftUI
import Foundation

@propertyWrapper
struct UserDefault<T> {
    private let userDefaults: UserDefaults
    private let key: String
    private let `default`: T

    var wrappedValue: T {
        get { userDefaults.object(forKey: key) as? T ?? `default` }
        set { userDefaults.set(newValue, forKey: key) }
    }

    init(userDefaults: UserDefaults = .standard, _ key: String, default: T) {
        self.userDefaults = userDefaults
        self.key = key
        self.default = `default`
    }
}

protocol LocalDatabaseType {
//    var databaseItems: [UUID] { get }

    func updateUserData(with mutation: DatabaseUserMutation) -> AnyPublisher<Void, SessionServiceError>
}

final class LocalDatabase: LocalDatabaseType {
    @Binding var userDetails: UserDetails
    @Binding var mutation: DatabaseUserMutation?

    @UserDefault("local_database_saved_ids_key", default: []) private(set) var savedIds: [String]

    init(userDetails: Binding<UserDetails>, mutation: Binding<DatabaseUserMutation?>) {
        self._userDetails = userDetails
        self._mutation = mutation
    }

    func updateUserData(with mutation: DatabaseUserMutation) -> AnyPublisher<Void, SessionServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else {
                    return promise(.failure(SessionServiceError.unowned))
                }
                
                var savedIds: [String] = userDetails.savedIds
                switch mutation {
                case let .add(item):
                    self.savedIds.append(item.id.uuidString)
                    savedIds.append(item.id.uuidString)
                case let .remove(item):
                    let newIds = savedIds.filter { $0 != item.id.uuidString }
                    self.savedIds = newIds
                    savedIds = newIds
                }

                self.userDetails.savedIds = savedIds
                self.mutation = mutation

                return promise(.success(()))
            }
        }
        .eraseToAnyPublisher()

    }
}
