import Combine
import Foundation
import Firebase

protocol LoginServiceType: EnvironmentType {
    func login(with credentials: LoginCredentials) -> AnyPublisher<Void, ServiceError>
}

struct LoginCredentials {
    var email: String
    var password: String
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
