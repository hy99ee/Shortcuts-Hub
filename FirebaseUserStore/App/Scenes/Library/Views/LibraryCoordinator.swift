import Foundation
import SwiftUI
import Combine

enum LibraryLink: TransitionType {
    case login
    case about(_ data: AboutViewData)
    case detail(_ item: Item)
    case error(_ error: Error)

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .login:
            hasher.combine(0)
        case .about:
            hasher.combine(1)
        case .detail:
            hasher.combine(2)
        case .error:
            hasher.combine(3)
        }
    }

    static func == (lhs: LibraryLink, rhs: LibraryLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

struct LibraryCoordinator: CoordinatorType {
    @State var path = NavigationPath()
    @State var fullcover: LibraryLink?
    @State var sheet: LibraryLink?
    @State var alert: LibraryLink?

    private var store: LibraryStore
    private var rootView: LibraryView
    let stateReceiver: AnyPublisher<LibraryLink, Never>

    init(store: LibraryStore) {
        self.store = store
        self.rootView = LibraryView(store: store)
        self.stateReceiver = store.transition.eraseToAnyPublisher()
    }
    
    var view: AnyView {
        AnyView(_view)
    }

    @ViewBuilder private var _view: some View {
        NavigationStack(path: $path) {
            ZStack {
                rootView
                    .fullScreenCover(item: $fullcover, content: fullcoverContent)
                    .sheet(item: $sheet, content: sheetContent)
                    .alert(item: $alert, content: alertContent)
            }
            .navigationDestination(for: LibraryLink.self, destination: linkDestination)
        }
    }

    func transitionReceiver(_ link: LibraryLink) {
        switch link {
        case .login:
            self.fullcover = link
        case .about:
            self.path.append(link)
        case .detail:
            self.path.append(link)
        case .error:
            self.alert = link
        }
    }

    @ViewBuilder private func linkDestination(link: LibraryLink) -> some View {
        switch link {
        case let .about(data):
            AboutView(aboutData: data)
        case let .detail(item):
            ItemDetailView(item: item)
        default:
            EmptyView()
        }
    }
    
    @ViewBuilder private func fullcoverContent(link: LibraryLink) -> some View {
        switch link {
        case .login:
            LoginCoordinator(store: store.packages.loginStore, parent: $fullcover)
        default:
            EmptyView()
        }
    }

    @ViewBuilder private func sheetContent(link: LibraryLink) -> some View {
        switch link {
        case let .detail(item):
            ItemDetailView(item: item)
        default:
            EmptyView()
        }
    }

    private func alertContent(link: LibraryLink) -> Alert {
        switch link {
        case let .error(error):
            return Alert(title: Text("Something went wrong"),
                  message: Text(error.localizedDescription),
                  dismissButton: .default(Text("OK")))
        default:
            return Alert(title: Text(""))
        }
    }
}

struct ItemDetailView: View {
//    @Environment(\.presentationMode) var presentationMode
    let item: Item

    @State private var image: Image?

    var body: some View {
        ScrollView(showsIndicators: false) {
            Text(item.title).padding()
            Text(item.description).padding()

            if let link = item.originalUrl, !link.isEmpty {
                Link(destination: URL(string: link)!) {
                    Image(systemName: "link.circle.fill")
                        .font(.largeTitle)
                }
                .padding()
            }

            if item.iconUrl != nil {
                imageView
                    .frame(width: 100, height: 100)
                    .cornerRadius(15)
            }
        }
        .navigationTitle("Detail")
        .onAppear {
            if let stringUrl = item.iconUrl?
                .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
               let url = URL(string: stringUrl) {
                downloadImage(from: url)
            }
        }
//        .toolbar {
//            ToolbarItem(placement: .navigationBarLeading) {
//                Button(action: {
//                    presentationMode.wrappedValue.dismiss()
//                }, label: {
//                    Text("Cancel")
//                })
//            }
//        }
    }
    
    
    @ViewBuilder private var imageView: some View {
        if image != nil {
            image!.resizable()
        } else {
            ZStack {
                Rectangle()
                    .foregroundColor(.secondary.opacity(0.3))

                HDotsProgress()
            }
        }
    }

    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }

    func downloadImage(from url: URL) {
        getData(from: url) { data, response, error in
            guard let data = data, error == nil else { return }

            if let image = UIImage(data: data) {
                self.image = Image(uiImage: image)
            }
        }
    }
}
