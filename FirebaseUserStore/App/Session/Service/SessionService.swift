import Foundation
import FirebaseAuth
import FirebaseDatabase
import Combine

enum SessionState {
    case loggedIn
    case loggedOut
    case loading
}

struct UserDetails {
    let storage: UserStorageDetails
    let auth: UserAuthDetails
}

struct UserStorageDetails {
    let firstName: String
    let lastName: String
    let occupation: String
}

struct UserAuthDetails {
    let email: (String, isVerified: Bool)
}

protocol SessionService: ObservableObject {
    var state: SessionState { get }
    var userDetails: UserDetails? { get }
    var makeSlice: SessionServiceSlice { get }

    init()

    func logout()
}

extension SessionService {
    var makeSlice: SessionServiceSlice { SessionServiceSlice(state: state, userDetails: userDetails, logout: logout) }
}
struct SessionServiceSlice {
    let state: SessionState
    let userDetails: UserDetails?
    let logout: () -> ()
}

final class SessionServiceImpl: SessionService, ObservableObject {
    @Published var state: SessionState = .loading
    @Published var userDetails: UserDetails?
    
    private var handler: AuthStateDidChangeListenerHandle?
    private var subscriptions = Set<AnyCancellable>()
    
    init() {
        setupObservations()
    }
    
    deinit {
        guard let handler = handler else { return }
        Auth.auth().removeStateDidChangeListener(handler)
        print("deinit SessionServiceImpl")
    }
    
    func logout() {
        try? Auth.auth().signOut()
    }
}

private extension SessionServiceImpl {
    func setupObservations() {
        handler = Auth
            .auth()
            .addStateDidChangeListener { [weak self] _,_ in
                guard let self = self else { return }
                
                let currentUser = Auth.auth().currentUser
                self.state = currentUser == nil ? .loggedOut : .loggedIn
                
                if let uid = currentUser?.uid {
                    
                    Database
                        .database()
                        .reference()
                        .child("users")
                        .child(uid)
                        .observe(.value) { [weak self] snapshot in
                            
                            guard let self = self,
                                  let value = snapshot.value as? NSDictionary,
                                  let firstName = value[RegistrationKeys.firstName.rawValue] as? String,
                                  let lastName = value[RegistrationKeys.lastName.rawValue] as? String,
                                  let occupation = value[RegistrationKeys.occupation.rawValue] as? String,
                                  let currentUser = currentUser else {
                                return
                            }

                            DispatchQueue.main.async {
                                self.userDetails = UserDetails(
                                    storage: UserStorageDetails(
                                        firstName: firstName,
                                        lastName: lastName,
                                        occupation: occupation),
                                    auth: UserAuthDetails(email: (mail: currentUser.email ?? "", isVerified: currentUser.isEmailVerified))
                                )
                            }
                        }
                }
            }
    }
}

final class MockSessionServiceImpl: SessionService, ObservableObject {
    @Published var state: SessionState = .loggedOut
    @Published var userDetails: UserDetails? = UserDetails(
        storage: UserStorageDetails(firstName: "Name", lastName: "Surname", occupation: "Occupation"),
        auth: UserAuthDetails(email: (mail: "string@mail.com", isVerified: false))
        )
    
    private var handler: AuthStateDidChangeListenerHandle?
    private var subscriptions = Set<AnyCancellable>()
    
    func logout() {}
}
