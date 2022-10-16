import SwiftUI

@available(iOS 16.0, *)
struct HomeView<
    Service: SessionService,
    Store: StateStore<
        FeedState,
        FeedCommitter,
        FeedDispatcher>
>: View {
    @ObservedObject var service: Service
    @EnvironmentObject var store: Store
    @EnvironmentObject var viewModel: HomeViewModel
    
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
                        ForEach(viewModel.items) {
                            Text($0.title)
                        }
                        .onMove {
                            viewModel.items.move(fromOffsets: $0, toOffset: $1)
                        }
                        .onDelete {
                            viewModel.removeItem($0)
                        }
                    }
                    .refreshable {
                        isRefresh = await viewModel.refreshItems()
                    }
            }

            
            
            .disabled(isRefresh)
            .opacity(isRefresh ? 0.5 : 1)

            ButtonView(title: "New") {
                viewModel.setNewItem()
            }
            .padding()
            
            ButtonView(title: "Update") {
                viewModel.fetchItems()
            }
            .padding()
            
            ButtonView(title: "FLUX") {
                store.dispatch(.startAction)
            }
            .padding()
        }
        .modifier(AlertShowViewModifier(provider: viewModel))
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
            HomeView(service: MockSessionServiceImpl())
                .environmentObject(HomeViewModel(with: ItemsService()))
        }
    }
}
