import SwiftUDF

class LoginPackages: EnvironmentPackagesWithSessionWithSession {
    private(set) var loginService = LoginService()
    
    lazy var registerStore = RegisterationStore(state: RegisterationState(), dispatcher: registerationDispatcher, reducer: registerationReducer, packages: RegisterationPackages())

    lazy var forgotStore = ForgotStore(state: ForgotState(), dispatcher: forgotDispatcher, reducer: forgotReducer, packages: ForgotPackages())

    func reinit() -> Self {
        loginService = LoginService()
        return self
    }
}
