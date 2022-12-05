import SwiftUI

struct FeedView: View {
    @EnvironmentObject var store: FeedStore
    
    @State var showLoader = false
    let heights = stride(from: 0.1, through: 1.0, by: 0.1).map { PresentationDetent.fraction($0) }
    
    @State var isRefresh = false
    let userDetailStore = SessionService.shared.userDetails
    var body: some View {
        mainView
    }
    
    @ViewBuilder
    var mainView: some View {
        VStack {
            VStack(alignment: .leading,
                   spacing: 16) {

                HStack {
                    Spacer()
                    Button {
                        store.dispatch(.showAboutSheet)
                    } label: {
                        Image(systemName: "person")
                    }
                }
                .padding()
            }
                   .padding(.horizontal, 16)

            NavigationView {
                    List {
                        ForEach(store.state.items) {
                            Text($0.title)
                        }
                        .onDelete {
                            let idsToDelete = $0.map { self.store.state.items[$0].id }
                            guard let id = idsToDelete.first else { return }

                            store.dispatch(.removeItem(id: id))
                        }

                    }
            }
            .modifier(ProgressViewModifier(provider: store.state.viewProgress))
            
            ButtonView(title: "NEW") {
                store.dispatch(.addItem)
            }
            .modifier(ButtonProgressViewModifier(provider: store.state.buttonProgress))
            .padding()
            
            ButtonView(title: "FLUX") {
                store.dispatch(.updateFeed)
            }
            .padding()

            ButtonView(title: "LOGOUT") {
                SessionService.shared.userDetails = nil
            }
            .padding()

            ButtonView(title: "LOGIN") {
                SessionService.shared.login()
            }
            .padding()
        }

        .modifier(AlertShowViewModifier(provider: store.state.alert))
        .modifier(SheetShowViewModifier(provider: store.state.aboutSheetProvider))
        .modifier(ProcessViewModifier(provider: store.state.processViewProgress))
        .onAppear {
            store.dispatch(.updateFeed)
        }
    }
}



extension PresentationDetent {
    static let bar = Self.fraction(0.2)
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        NavigationView {
//            FeedView()
//                .environmentObject(
//                    StateStore(
//                        state: FeedState(),
//                        dispatcher: loginDispatcher,
//                        reducer: feedReducer,
//                        packages: FeedPackages()
//                    )
//                )
//        }
//    }
//}
