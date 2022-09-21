import SwiftUI

struct HomeView<Service: SessionService>: View {
    @ObservedObject var service: Service
    @EnvironmentObject var viewModel: HomeViewModel
    
    var body: some View {
        mainView
    }
    
    @ViewBuilder
    var mainView: some View {
        VStack {
            VStack(alignment: .leading,
                   spacing: 16) {
                
                VStack(alignment: .leading,
                       spacing: 16) {
                    Text("First Name: \(service.userDetails?.firstName ?? "")")
                    Text("Last Name: \(service.userDetails?.lastName ?? "")")
                    Text("Occupation: \(service.userDetails?.occupation ?? "")")
                }
                       .padding()
                
                ButtonView(title: "New") {
                    viewModel.setNewItem()
                }
                
                Text("Items count: \(String(viewModel.items.count))")
                    .padding()
            }
                   .padding(.horizontal, 16)
                   .navigationTitle("Main ContentView")
            
            NavigationView {
                VStack {
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
                    .toolbar { EditButton() }
                }
            }
            
            ButtonView(title: "Logout") {
                service.logout()
            }
            .padding()
        }
        .modifier(AlertShowViewModifier(provider: viewModel))
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView(service: SessionServiceImpl())
                .environmentObject(HomeViewModel(with: ItemsService()))
        }
    }
}
