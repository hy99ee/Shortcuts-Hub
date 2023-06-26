import SwiftUI

struct ItemDetailView: View {
    @StateObject var store: DetailItemStore

    @State private var image: Image?
    private let shortcutsApiManager = ShortcutsApiManager()

    var body: some View {
        NavigationView {
            ZStack {
                Color(rgb: store.state.item.colorValue ?? 255).opacity(0.5)
                ScrollView(showsIndicators: false) {
                    VStack {
                        Text(store.state.item.description).padding()

                        if let link = store.state.item.originalUrl, !link.isEmpty {
                            Link(destination: URL(string: link)!) {
                                Image(systemName: "link.circle.fill")
                                    .font(.largeTitle)
                            }
                            .padding()
                        }

                        if store.state.item.icon != nil {
                            imageView
                                .frame(width: 100, height: 100)
                                .cornerRadius(15)
                        }

                        HStack {
                            Spacer()

                            Button {
                                shortcutsApiManager.call(.run(name: store.state.item.title))
                            } label: {
                                Image(systemName: "play.square")
                                    .frame(width: 50, height: 50)
                                    .padding()
                            }
                        }

                    }
    
                }
//                .scrollBounceBehavior(.basedOnSize)
                .onAppear {
                    if let iconData = store.state.item.icon, let image = UIImage(data: iconData) {
                        self.image = Image(uiImage: image)
                    }
                }
                .toolbar {
                    if store.state.item.userId != store.packages.sessionService.userDetails.auth?.id {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            toggleFavoritesButton
                                .modifier(ButtonClearProgressViewModifier(progressStatus: store.state.viewProgress))
                        }
                    }
                }
                .navigationBarTitle(store.state.item.title, displayMode: .automatic)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {

        }
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

    private var toggleFavoritesButton: Button<Image> {
        Button(action: {
            store.dispatch(store.state.item.isSaved ? .removeFromSaved : .addToSaved)
        }, label: {
            Image(systemName: store.state.item.isSaved ? "heart.fill" : "heart")
        })
    }
}
