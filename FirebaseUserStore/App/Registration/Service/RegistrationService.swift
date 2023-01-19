import Combine
import Foundation
import Firebase
import FirebaseDatabase

enum RegistrationCredentialsField: CaseIterable {
    case email
    case phone
    case password
    case conformPassword
    case firstName
    case lastName
}
struct RegistrationCredentials {
    var email = ""
    var phone = ""
    var password: String = ""
    var conformPassword: String = ""
    var firstName: String = ""
    var lastName: String = ""
}
extension RegistrationCredentials {
    func credentialsField(_ field: RegistrationCredentialsField) -> String {
        switch field {
        case .email:
            return self.email
        case .phone:
            return self.phone
        case .password:
            return self.password
        case .conformPassword:
            return self.conformPassword
        case .firstName:
            return self.firstName
        case .lastName:
            return self.lastName
        }
    }
    var isValid: Bool {
        email.isEmail &&
        phone.isPhone &&
        password.isPassword &&
        conformPassword.isPassword &&
        firstName.isUsername &&
        lastName.isUsername
    }
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
                                          RegistrationKeys.lastName.rawValue: credentials.lastName] as [String : Any]
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
