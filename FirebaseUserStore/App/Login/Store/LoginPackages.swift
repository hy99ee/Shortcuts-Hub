import Foundation

class LoginPackages: EnvironmentPackages {
    private(set) var loginService = LoginService()

    func reinit() -> Self {
        loginService = LoginService()
        return self
    }
}
