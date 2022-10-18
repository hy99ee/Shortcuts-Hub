import SwiftUI
import Firebase

final class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct Firebase_User_Account_ManagementApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject var sessionService = SessionServiceImpl()
    
    var body: some Scene {
        WindowGroup {
            switch sessionService.state {
            case .loggedIn:
                HomeView(service: sessionService, store: StateStore(state: FeedState(), committer: FeedCommitter(), dispatcher: FeedDispatcher()))
                    .environmentObject(HomeViewModel(with: ItemsService()))
//                    .environmentObject(StateStore(state: FeedState(), committer: FeedCommitter(), dispatcher: FeedDispatcher()))
            case .loggedOut:
                LoginView()
            case .loading:
                ProgressView()
            }
        }
    }
}
