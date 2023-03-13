import Combine
import Firebase
import FirebaseDatabase

protocol RegistrationServiceType: EnvironmentType {
    func register(with credentials: RegistrationCredentials) -> AnyPublisher<Void, ServiceError>
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
                            let values = [
                                RegistrationKeys.firstName.rawValue: credentials.firstName,
                                RegistrationKeys.lastName.rawValue: credentials.lastName,
                                RegistrationKeys.phone.rawValue: credentials.phone
                            ] as [String : Any]
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
//        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
