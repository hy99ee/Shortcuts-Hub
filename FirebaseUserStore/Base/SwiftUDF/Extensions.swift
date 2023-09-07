import SwiftUDF

protocol EnvironmentPackagesWithSessionWithSession: EnvironmentPackages {
    var sessionService: SessionService { get }
}

extension EnvironmentPackagesWithSessionWithSession {
    var sessionService: SessionService { SessionService.shared }
}
