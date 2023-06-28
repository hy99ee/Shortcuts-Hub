import Combine
import SwiftUDF
import SwiftUI

class ForgotPackages: EnvironmentPackagesWithSessionWithSession, Unreinitable {
    lazy var forgotService = ForgotPasswordService()
}
