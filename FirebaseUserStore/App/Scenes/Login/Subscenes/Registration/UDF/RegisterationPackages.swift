import SwiftUDF

class RegisterationPackages: EnvironmentPackagesWithSessionWithSession, Unreinitable {
    lazy var registerationService = RegistrationService()
}
