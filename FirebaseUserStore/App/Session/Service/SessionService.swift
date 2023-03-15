import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Combine

protocol SessionServiceType: ObservableObject {
    var state: SessionState { get }
    var userDetails: UserDetails? { get }

    func logout()
}

struct SessionServiceSlice {
    let state: SessionState
    let userDetails: UserDetails?
    let logout: () -> ()
}

final class SessionService: SessionServiceType, ObservableObject {
    static let shared = SessionService()
    @Published var state: SessionState = .loading
    @Published var userDetails: UserDetails?
    
    private var handler: AuthStateDidChangeListenerHandle?
    private var subscriptions = Set<AnyCancellable>()
    
    private init() {
        setupObservations()
    }

    func login() {
        let auth = self.auth()
            .retry(3)
            .replaceError(with: nil)
            .share()

        auth
            .compactMap { $0 }
            .assign(to: &$userDetails)
        
        auth
            .map { $0 == nil ? SessionState.loggedOut : SessionState.loggedIn }
            .assertNoFailure()
            .assign(to: &$state)
    }

    func logout() {
        try? Auth.auth().signOut()
    }

    func deleteUser() {
        Auth.auth().currentUser?.delete()
    }

    func syncNewUserWithDatabase(_ credentials: RegistrationCredentials) -> AnyPublisher<Void, SessionServiceError> {
        Deferred {
            Future { promise in
                let currentUser = Auth.auth().currentUser

                guard let uid = currentUser?.uid else { return promise(.failure(.errorWithAuth)) }

                let databaseUser = DatabaseUser(
                    firstName: credentials.firstName,
                    lastName: credentials.lastName,
                    phone: credentials.phone,
                    //                                savedIds: []
                    savedIds: ["4716E007-FF50-41CC-ACA2-8960B549DACF"]
                )
                Database
                    .database()
                    .reference()
                    .child("users")
                    .child(uid)
                    .updateChildValues(databaseUser.databaseFormat) { error, ref in
                        if error != nil {
                            return promise(.failure(.errorWithAuth))
                        } else {
                            return promise(.success(()))
                        }
                    }
            }
            
        }.eraseToAnyPublisher()
    }
}

private extension SessionService {
    func setupObservations() {
        handler = Auth
            .auth()
            .addStateDidChangeListener { [weak self] _,_ in
                guard let self = self else { return }
                
                let currentUser = Auth.auth().currentUser
                
                if let uid = currentUser?.uid {
                    Database
                        .database()
                        .reference()
                        .child("users")
                        .child(uid)
                        .observe(.value) { [weak self] snapshot in
                            guard let self = self,
                                  let value = snapshot.value as? NSDictionary,
                                  let firstName = value[DatabaseUserKeys.firstName.rawValue] as? String,
                                  let lastName = value[DatabaseUserKeys.lastName.rawValue] as? String,
                                  let phone = value[DatabaseUserKeys.phone.rawValue] as? String,
                                  let savedIds = value[DatabaseUserKeys.savedIds.rawValue] as? [String],
                                  let currentUser = currentUser else {
                                self?.state = .loggedOut
                                return
                            }

                            DispatchQueue.main.async {
                                self.state = .loggedIn
                                self.userDetails = UserDetails(
                                    value: DatabaseUser(
                                        firstName: firstName,
                                        lastName: lastName,
                                        phone: phone,
                                        savedIds: savedIds
                                    ),
                                    auth: UserAuthDetails(email: (mail: currentUser.email ?? "", isVerified: currentUser.isEmailVerified))
                                )
                            }
                        }
                } else {
                    self.state = .loggedOut
                }
            }
    }

    func auth() -> AnyPublisher<UserDetails?, SessionServiceError>  {
        Deferred {
            Future { promise in
                let currentUser = Auth.auth().currentUser

                if let uid = currentUser?.uid {
                    Database
                        .database()
                        .reference()
                        .child("users")
                        .child(uid)
                        .observe(.value) { snapshot in
                            guard
                                  let value = snapshot.value as? NSDictionary,
                                  let firstName = value[DatabaseUserKeys.firstName.rawValue] as? String,
                                  let lastName = value[DatabaseUserKeys.lastName.rawValue] as? String,
                                  let phone = value[DatabaseUserKeys.phone.rawValue] as? String,
                                  let savedIds = value[DatabaseUserKeys.savedIds.rawValue] as? [String],
                                  let currentUser = currentUser else {
                                return promise(.success(nil))
                            }

                            let userDetails = UserDetails(
                                value: DatabaseUser(
                                    firstName: firstName,
                                    lastName: lastName,
                                    phone: phone,
                                    savedIds: savedIds
                                ),
                                auth: UserAuthDetails(email: (mail: currentUser.email ?? "", isVerified: currentUser.isEmailVerified))
                            )
                            promise(.success(userDetails))
                        }
                } else {
                    promise(.failure(.errorWithAuth))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

final class MockSessionService: SessionServiceType, ObservableObject {
    @Published var state: SessionState = .loggedOut
    @Published var userDetails: UserDetails? = UserDetails(
        value: DatabaseUser(firstName: "Name", lastName: "Surname", phone: "89008007060", savedIds: []),
        auth: UserAuthDetails(email: (mail: "string@gmail.com", isVerified: false))
        )

    var makeSlice: SessionServiceSlice { SessionServiceSlice(state: state, userDetails: nil, logout: logout) }
    
    private var handler: AuthStateDidChangeListenerHandle?
    private var subscriptions = Set<AnyCancellable>()
    
    func logout() {}
}

enum SessionState {
    case loggedIn
    case loggedOut
    case loading
}

struct UserDetails {
    let value: DatabaseUser
    let auth: UserAuthDetails
}

struct UserAuthDetails {
    let email: (String, isVerified: Bool)
}
