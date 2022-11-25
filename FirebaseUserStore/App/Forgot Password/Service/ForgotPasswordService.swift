import Foundation
import Firebase
import Combine

protocol ForgotPasswordServiceType: EnvironmentType {
    func sendPasswordResetRequest(to email: String) -> AnyPublisher<Void, ServiceError>
}

final class ForgotPasswordService: ForgotPasswordServiceType {
    typealias ServiceError = ForgotServiceError

    func sendPasswordResetRequest(to email: String) -> AnyPublisher<Void, ServiceError> {
        Deferred {
            Future { promise in
                promise(.failure(.mockError))
                Auth
                    .auth()
                    .sendPasswordReset(withEmail: email) { error in
                        
                        if let err = error {
                            promise(.failure(.firebaseError(err)))
                        } else {
                            promise(.success(()))
                        }
                    }
            }
        }
        .eraseToAnyPublisher()
    }
}
