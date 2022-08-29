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
//            HomeView()
//                .environmentObject(sessionService)
//                .environmentObject(HomeViewModel())
//            NavigationView {
                switch sessionService.state {
                    case .loggedIn:
                        HomeView()
                            .environmentObject(sessionService)
                            .environmentObject(HomeViewModel(with: ItemsService()))
                    case .loggedOut:
                        LoginView()
                    }

//            }
        }
    }
}
