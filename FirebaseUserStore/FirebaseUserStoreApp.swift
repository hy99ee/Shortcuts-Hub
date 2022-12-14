import SwiftUI
import Firebase

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
    @StateObject var sessionService = SessionService.shared

    private let storeRepository = StoreRepository.shared

    var body: some Scene {
        WindowGroup {
            switch sessionService.state {
            case .loggedIn:
                FeedView()
                    .environmentObject(storeRepository.feedStore)
            case .loggedOut:
                LoginView()
                    .environmentObject(storeRepository.loginStore)
            case .loading:
                HDotsProgress().scaleEffect(2)
            }
        }
    }
}
