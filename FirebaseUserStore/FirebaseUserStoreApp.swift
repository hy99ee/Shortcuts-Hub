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

    private let storeRepository = GlobalStoreRepository.shared

    var body: some Scene {
        WindowGroup {
            GlobalCoordinator()
        }
    }
}
