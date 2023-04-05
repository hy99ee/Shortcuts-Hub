import Foundation

class ForgotPackages: EnvironmentPackages, Unreinitable {
    lazy var forgotService = ForgotPasswordService()
}
