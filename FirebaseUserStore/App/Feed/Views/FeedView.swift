import SwiftUI

struct FeedView<Service: SessionService, Store: FeedStore>: View {
    var service: Service
    @EnvironmentObject var store: Store
//    @EnvironmentObject var viewModel: HomeViewModel
    
    @State var showAbout = false
    @State var showLoader = false
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
                        store.dispatch(.showAboutSheet(serviceData: service.makeSlice))
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
            .disabled(isRefresh)
            .opacity(isRefresh ? 0.5 : 1)
            
            ButtonView(title: "NEW") {
                store.dispatch(.addItem)
            }
            .padding()
            
            ButtonView(title: "FLUX") {
                store.dispatch(.updateFeed)
            }
            .padding()
        }
        .modifier(AlertShowViewModifier(provider: store.state.alertProvider))
        .modifier(SheetShowViewModifier(provider: store.state.aboutSheetProvider))
        .onAppear {
            store.dispatch(.updateFeed)
        }
    }
        
}


extension PresentationDetent {
    static let bar = Self.fraction(0.2)
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            FeedView(service: MockSessionServiceImpl())
                .environmentObject(
                    StateStore(
                        state: FeedState(),
                        dispatcher: FeedDispatcher(environment: ItemsService()),
                        reducer: feedReducer
                    )
                )
        }
    }
}
