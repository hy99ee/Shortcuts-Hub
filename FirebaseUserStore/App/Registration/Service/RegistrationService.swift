import Combine
import Foundation
import Firebase
import FirebaseDatabase

struct RegistrationCredentials {
    var email: String
    var password: String
    var firstName: String
    var lastName: String
    var occupation: String
}

protocol RegistrationServiceType: EnvironmentType {
    func register(with credentials: RegistrationCredentials) -> AnyPublisher<Void, ServiceError>
}

enum RegistrationKeys: String {
    case firstName
    case lastName
    case occupation
}

final class RegistrationService: RegistrationServiceType {
    typealias ServiceError = RegistrationServiceError
    
    func register(with credentials: RegistrationCredentials) -> AnyPublisher<Void, RegistrationServiceError> {
        Deferred {
            Future { promise in
                Auth.auth().createUser(
                    withEmail: credentials.email,
                    password: credentials.password) { res, error in
                        if let err = error {
                            promise(.failure(.firebaseError(err)))
                        }
                        if let uid = res?.user.uid {
                            let values = [RegistrationKeys.firstName.rawValue: credentials.firstName,
                                          RegistrationKeys.lastName.rawValue: credentials.lastName,
                                          RegistrationKeys.occupation.rawValue: credentials.occupation] as [String : Any]
                            Database
                                .database()
                                .reference()
                                .child("users")
                                .child(uid)
                                .updateChildValues(values) { error, ref in
                                    if let err = error {
                                        promise(.failure(.firebaseError(err)))
                                    } else {
                                        promise(.success(()))
                                    }
                                }
                        }
                        
                    }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
