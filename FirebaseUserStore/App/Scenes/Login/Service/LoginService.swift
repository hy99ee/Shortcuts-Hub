import Combine
import SwiftUDF
import Firebase

protocol LoginServiceType: EnvironmentType {
    associatedtype ServiceError: Error

    func login(with credentials: LoginCredentials) -> AnyPublisher<Void, ServiceError>
}

final class LoginService: LoginServiceType {
    typealias ServiceError = LoginServiceError
    
    func login(with credentials: LoginCredentials) -> AnyPublisher<Void, ServiceError> {
        Deferred {
            Future { promise in
                Auth
                    .auth()
                    .signIn(withEmail: credentials.email,
                            password: credentials.password) { res, error in
                        if let err = error {
                            promise(.failure(.firebaseError(err)))
                        } else {
                            promise(.success(()))
                        }
                    }
            }
        }
        .receive(on: RunLoop.main)
        .eraseToAnyPublisher()
    }
}
