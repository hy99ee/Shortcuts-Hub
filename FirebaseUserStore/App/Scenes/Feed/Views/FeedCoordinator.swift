import Foundation
import SwiftUI
import Combine

enum FeedLink: TransitionType {
    case section(_ section: IdsSection)
    case error(_ error: Error)

    var id: String {
        String(describing: self)
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .section:
            hasher.combine(0)
        case .error:
            hasher.combine(1)
        }
    }

    static func == (lhs: FeedLink, rhs: FeedLink) -> Bool {
        lhs.hashValue == rhs.hashValue
    }
}

class NamespaceWrapper: ObservableObject {
    var namespace: Namespace.ID

    init(_ namespace: Namespace.ID) {
        self.namespace = namespace
    }
}

struct FeedCoordinator: CoordinatorType {
    @State var path = NavigationPath()
    @State var alert: FeedLink?
    @State var custom: FeedLink?

    @Namespace var open

    private let store: FeedStore
    private let feedView: FeedView
    let stateReceiver: AnyPublisher<FeedLink, Never>

    init(store: FeedStore) {
        self.store = store
        self.feedView = FeedView(store: store)
        self.stateReceiver = store.transition.eraseToAnyPublisher()
    }
    
    var view: AnyView {
        AnyView(_view)
    }

    @ViewBuilder private var _view: some View {
        NavigationStack(path: $path) {
            ZStack {
                rootView
                    .alert(item: $alert, content: alertContent)
            }
            .navigationDestination(for: FeedLink.self, destination: linkDestination)
        }
    }

    @ViewBuilder private var rootView: some View {
        if custom == nil {
            feedView
                .environmentObject(NamespaceWrapper(open))
                .padding(custom == nil ? 10 : 0)
                .disabled(custom != nil)
        } else {
            FeedDetailView(link: $custom)
                .environmentObject(NamespaceWrapper(open))
        }
    }

    func transitionReceiver(_ link: FeedLink) {
        switch link {
        case .section:
            withAnimation(.spring()) {
                custom = link
            }
        case .error:
            self.alert = link
        }
    }

    @ViewBuilder private func linkDestination(link: FeedLink) -> some View {
        switch link {
        case let .section(section):
            Text(section.title)
        default:
            EmptyView()
        }
    }



    private func alertContent(link: FeedLink) -> Alert {
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


struct FeedDetailView: View {
    @Binding var link: FeedLink?
    @State var detailScale: CGFloat = 1
    @State private var lastOffsetY: Double = 0
    @State private var animation = true

    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    var body: some View {
        if case let link, let link {
            if case let FeedLink.section(section) = link {
                OffsetObservingScrollView(scale: $detailScale) {
                    VStack {
                        ItemsSectionView(section: section, isDetail: true)
                            .frame(height: 470)
                        
                        detailContent(section: section)
                            .onTapGesture {
                                withAnimation(.spring()) {
                                    self.link = nil
                                }
                            }
                    }
                }
                .edgesIgnoringSafeArea(.horizontal)
                .matchedGeometryEffect(id: section.id, in: namespaceWrapper.namespace, anchor: .center)
                .onChange(of: detailScale) {
                    if $0 < 0.9 {
                        withAnimation(.spring()) {
                            self.link = nil
                            detailScale = 1
                        }
                    }
                }
            }
        }
    }

    private func detailContent(section: IdsSection) -> some View {
        ZStack {
            Rectangle()
                
                .cornerRadius(10)

            ScrollView {
                VStack {
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                }
                VStack {
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                }
                VStack {
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                }
                VStack {
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                    Text("Heeloo")
                }
            }
            .foregroundColor(.blue)
        }
        .animation(.spring(), value: animation)
        .transition(.scale)
//        .ignoresSafeArea()
//        .applyClose(.view)
    }
}
