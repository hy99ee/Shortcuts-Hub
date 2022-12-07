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
    
    let loginStore = LoginStore(
        state: LoginState(),
        dispatcher: loginDispatcher,
        reducer: loginReducer,
        packages: LoginPackages(),
        middlewares: [LoginStore.middleware1, LoginStore.middleware1]
        )
    let feedStore = StateStore(
        state: FeedState(),
        dispatcher: feedDispatcher,
        reducer: feedReducer,
        packages: FeedPackages(),
        middlewares: [FeedStore.middleware5]
    )
    
    var body: some Scene {
        WindowGroup {
            switch sessionService.state {
            case .loggedIn:
                FeedView()
                    .environmentObject(feedStore)
            case .loggedOut:
                LoginView()
                    .environmentObject(loginStore)
            case .loading:
                ProgressView().scaleEffect(1.2)
            }
        }
    }
}
