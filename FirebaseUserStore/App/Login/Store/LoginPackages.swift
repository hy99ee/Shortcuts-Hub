import Foundation

class LoginPackages: EnvironmentPackages {
    typealias PackageLoginService = LoginService
    typealias PackageRegistrationService = RegistrationService
    typealias PackageForgotService = ForgotPasswordService

    lazy var loginService = PackageLoginService()
    lazy var registrationService = PackageRegistrationService()
    lazy var forgotService = PackageForgotService()
}
