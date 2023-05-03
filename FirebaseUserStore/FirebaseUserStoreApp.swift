import SwiftUI
import Firebase
import Foundation

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
            FirebaseApp.configure()

            return true
    }
}

@main
struct Firebase_User_Account_ManagementApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    var utilities = Utilities.shared

    var body: some Scene {
        WindowGroup {
            GlobalCoordinator()
                .onAppear {
                    utilities.overrideDisplayMode()
                }
        }
    }
}
