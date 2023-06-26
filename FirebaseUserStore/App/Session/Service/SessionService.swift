import Foundation
import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Combine

protocol SessionServiceType: ObservableObject {
    var state: SessionState { get }
    var userDetails: UserDetails { get }

    func logout()
}

struct SessionServiceSlice {
    let state: SessionState
    let userDetails: UserDetails
    let logout: () -> ()
}

final class SessionService: SessionServiceType, ObservableObject {
    static let shared = SessionService()
    @Published var state: SessionState = .loading
    @Published var userDetails = UserDetails()
    @Published var databaseMutation: UserItemsMutation?
    @Published var firestoreMutation: UserItemsMutation?

    private var remoteDatabase: (any RemoteDatabaseType)!
    private var localDatabase: (any LocalDatabaseType)!
    
    private var handler: AuthStateDidChangeListenerHandle?
    private var subscriptions = Set<AnyCancellable>()
    
    private init() {
        let databaseMutation = mutationBinding
        let databaseUserDetail = userDetailBinding
        self.remoteDatabase = RemoteDatabase(userDetails: databaseUserDetail, mutation: databaseMutation)
        self.localDatabase = LocalDatabase(userDetails: databaseUserDetail, mutation: databaseMutation)

        setupObservations()
    }

    func logout() {
        try? Auth.auth().signOut()
    }

    func deleteUser() {
        Auth.auth().currentUser?.delete()
    }

    func syncNewUserWithDatabase(_ credentials: RegistrationCredentials) -> AnyPublisher<Void, SessionServiceError> {
        guard let userId = userDetails.auth?.id else {
            return Fail(error: SessionServiceError.errorWithAuth).eraseToAnyPublisher()
        }
    
        return remoteDatabase.syncNewUser(credentials, for: userId)
    }

    func updateDatabaseUser(with mutation: UserItemsMutation) -> AnyPublisher<Void, SessionServiceError> {
        self.state == .loggedIn ? remoteDatabase.updateUserData(with: mutation) : localDatabase.updateUserData(with: mutation)
    }

    private var userDetailBinding: Binding<UserDetails> {
        Binding<UserDetails> {
            self.userDetails
        } set: { newValue in
            self.userDetails = newValue
        }
    }

    private var mutationBinding: Binding<UserItemsMutation?> {
        Binding<UserItemsMutation?> {
            self.databaseMutation
        } set: { newValue in
            self.databaseMutation = newValue
        }
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
                        .observe(.value) { [weak self] snapshot  in
                            guard let self = self,
                                  let value = snapshot.value as? NSDictionary,
                                  let currentUser = currentUser,
                                  let firstName = value[DatabaseUserKeys.firstName.rawValue] as? String,
                                  let lastName = value[DatabaseUserKeys.lastName.rawValue] as? String,
                                  let phone = value[DatabaseUserKeys.phone.rawValue] as? String
                            else {
                                self?.state = .loggedOut
                                self?.userDetails = UserDetails(
                                    value: nil,
                                    auth: nil,
                                    savedIds: []
                                )
                                return
                            }
                            let savedIds = value[DatabaseUserKeys.savedIds.rawValue] as? [String] ?? [String]()

                            DispatchQueue.main.async {
                                self.state = .loggedIn
                                self.userDetails = UserDetails(
                                    value: DatabaseUser(
                                        firstName: firstName,
                                        lastName: lastName,
                                        phone: phone
                                    ),
                                    auth: UserAuthDetails(
                                        id: currentUser.uid,
                                        email: (mail: currentUser.email ?? "", isVerified: currentUser.isEmailVerified)
                                    ),
                                    savedIds: savedIds
                                )
                            }
                        }
                } else {
                    self.state = .loggedOut
                    self.userDetails = UserDetails(
                        value: nil,
                        auth: nil,
                        savedIds: localDatabase.savedIds
                    )
                }
            }
    }
}

enum SessionState {
    case loggedIn
    case loggedOut
    case loading
}

struct UserDetails: Equatable {
    var value: DatabaseUser?
    var auth: UserAuthDetails?
    var savedIds: [String] = []
}

struct UserAuthDetails: Equatable {
    let id: String
    let email: (String, isVerified: Bool)

    static func == (lhs: UserAuthDetails, rhs: UserAuthDetails) -> Bool {
        lhs.id == rhs.id && lhs.email == rhs.email
    }
}



final class MockSessionService: SessionServiceType, ObservableObject {
    @Published var state: SessionState = .loggedOut
    @Published var userDetails = UserDetails(
        value: DatabaseUser(firstName: "Name", lastName: "Surname", phone: "89008007060"),
        auth: UserAuthDetails(
            id: Auth.auth().currentUser?.uid ?? "",
            email: (mail: "string@gmail.com", isVerified: false)),
        savedIds: []
        )

    var makeSlice: SessionServiceSlice { SessionServiceSlice(state: state, userDetails: userDetails, logout: logout) }
    
    private var handler: AuthStateDidChangeListenerHandle?
    private var subscriptions = Set<AnyCancellable>()
    
    func logout() {}
}
