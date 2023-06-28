import Combine
import SwiftUDF
import Firebase

protocol ForgotPasswordServiceType: EnvironmentPackagesWithSessionWithSession, Unreinitable {
    associatedtype ServiceError: Error

    func sendPasswordResetRequest(to email: String) -> AnyPublisher<Void, ServiceError>
}

final class ForgotPasswordService: ForgotPasswordServiceType {
    typealias ServiceError = ForgotServiceError

    func sendPasswordResetRequest(to email: String) -> AnyPublisher<Void, ServiceError> {
        Deferred {
            Future { promise in
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
