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
                        promise(.success(()))
                    }
            }
        }
        .eraseToAnyPublisher()
    }
}
