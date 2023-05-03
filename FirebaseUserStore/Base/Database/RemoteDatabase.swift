import Combine
import SwiftUI
import FirebaseDatabase

protocol RemoteDatabaseType {
    var userDetails: UserDetails { get }
    var mutation: DatabaseUserMutation? { get }
    
    func updateUserData(with mutation: DatabaseUserMutation, for userId: String?) -> AnyPublisher<Void, SessionServiceError>
    func syncNewUser(_ credentials: RegistrationCredentials, for userId: String) -> AnyPublisher<Void, SessionServiceError>
}

enum DatabaseUserKeys: String {
    case firstName
    case lastName
    case phone
    case savedIds
}

final class RemoteDatabase: RemoteDatabaseType {
    @Binding var userDetails: UserDetails
    @Binding var mutation: DatabaseUserMutation?

    init(userDetails: Binding<UserDetails>, mutation: Binding<DatabaseUserMutation?>) {
        self._userDetails = userDetails
        self._mutation = mutation
    }
    
    func updateUserData(with mutation: DatabaseUserMutation, for userId: String?) -> AnyPublisher<Void, SessionServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard
                    let self,
                    let userId
                else {
                    return promise(.failure(.errorWithAuth))
                }

                var savedIds: [String] = self.userDetails.savedIds
                switch mutation {
                case let .add(item):
                    savedIds.append(item.id.uuidString)
                case let .remove(item):
                    savedIds = userDetails.savedIds.filter { $0 != item.id.uuidString }
                }

                Database
                    .database()
                    .reference()
                    .child("users")
                    .child(userId)
                    .updateChildValues(self.makeSavedIdsForDatabaseFormat(savedIds)) { error, ref in
                        if error != nil {
                            return promise(.failure(.errorWithAuth))
                        } else {
                            self.userDetails.savedIds = savedIds
                            self.mutation = mutation
                            return promise(.success(()))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }

    func syncNewUser(_ credentials: RegistrationCredentials, for userId: String) -> AnyPublisher<Void, SessionServiceError> {
        Deferred {
            Future {[weak self] promise in
                guard let self else {
                    return promise(.failure(.errorWithAuth))
                }
                
                let newUser = DatabaseUser(
                    firstName: credentials.firstName,
                    lastName: credentials.lastName,
                    phone: credentials.phone
                )

                Database
                    .database()
                    .reference()
                    .child("users")
                    .child(userId)
                    .updateChildValues(self.makeNewUserForDatabaseFormat(newUser)) { error, ref in
                        if error != nil {
                            return promise(.failure(.errorWithAuth))
                        } else {
                            return promise(.success(()))
                        }
                    }
            }
            
        }.eraseToAnyPublisher()
    }

    private func makeSavedIdsForDatabaseFormat(_ savedIds: [String]) -> [String: Any] {
        [
            DatabaseUserKeys.savedIds.rawValue: savedIds
        ]
    }
    
    private func makeNewUserForDatabaseFormat(_ user: DatabaseUser) -> [String: Any] {
        [
            DatabaseUserKeys.firstName.rawValue: user.firstName,
            DatabaseUserKeys.lastName.rawValue: user.lastName,
            DatabaseUserKeys.phone.rawValue: user.phone,
            DatabaseUserKeys.savedIds.rawValue: [String]()
        ]
    }
}
