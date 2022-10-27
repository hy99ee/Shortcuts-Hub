import SwiftUI

typealias FeedStore = StateStore<FeedState, FeedDispatcher<ItemsService>>
struct HomeView<Service: SessionService, Store: FeedStore>: View {
    var service: Service
    @ObservedObject var store: Store
//    @EnvironmentObject var viewModel: HomeViewModel
    
    @State var showAbout = false
    let heights = stride(from: 0.1, through: 1.0, by: 0.1).map { PresentationDetent.fraction($0) }
    
    @State var isRefresh = false

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
                        showAbout.toggle()
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
                        .onMove { _, _ in
//                            viewModel.items.move(fromOffsets: $0, toOffset: $1)
                        }
                        .onDelete { _ in
//                            viewModel.removeItem($0)
                        }
                    }
            }
            
            .disabled(isRefresh)
            .opacity(isRefresh ? 0.5 : 1)
            
//            ButtonView(title: "Update") {
//                viewModel.fetchItems()
//            }
//            .padding()
            
            ButtonView(title: "FLUX") {
                store.dispatch(.updateFeed)
            }
            .padding()
        }
        .modifier(AlertShowViewModifier(provider: store.state))
        .sheet(isPresented: $showAbout) {
            AboutView(
                user: service.userDetails!,
                logout: {
                    service.logout()
                    showAbout = false
                })
            .presentationDetents([.height(200), .medium])
        }
        .disabled(service.userDetails == nil)
    }
}


extension PresentationDetent {
    static let bar = Self.fraction(0.2)
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(
                service: MockSessionServiceImpl(),
                store:
                    StateStore(
                        state: FeedState(),
                        dispatcher: FeedDispatcher(environment: ItemsService()),
                        reducer: feedReducer
                    )
            )
        }
    }
}
