import SwiftUI

struct ItemDetailView: View {
    @StateObject var store: DetailItemStore

    @State private var image: Image?
    private let shortcutsApiManager = ShortcutsApiManager()

    var body: some View {
            ZStack {
//                LinearGradient(stops: [(store.state.item.colorValue ?? .max), Color.clear], startPoint: .topLeading, endPoint: .bottomTrailing).opacity(0.3)
//                Color(rgb: store.state.item.colorValue ?? 9999999)


//                LinearGradient(colors: [ShortcutsColor.darkOrange.color, Color(uiColor: .darkGray)], startPoint: .top, endPoint: .bottom)
//                    .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack {
                        HStack {
                            imageView
                                    .frame(width: 130, height: 130)
                                    .cornerRadius(16)
//                                    .padding()

                            VStack {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(store.state.item.title)
//                                        Text("Tasdaaaaaaaa")
                                            .font(
                                                .system(
                                                    store.state.item.title.count < 13
                                                    ? .title
                                                    : store.state.item.title.count > 18
                                                      ? .title3
                                                      : .title2
                                                )
                                            )
                                            .bold()

                                        Text(store.state.item.description)
                                            .font(.system(.headline))
                                            .foregroundColor(.secondary)
                                    }

                                    Spacer()
                                }
                                .padding(.bottom, 6)

                                Spacer()

                                HStack {
                                    Link(destination: URL(string: "https://console.developers.google.com")!) {
                                        Text("Get")
                                            .bold()
                                            .foregroundColor(.white)
                                            .background(.blue)
                                            .frame(minWidth: 80, minHeight: 35)

                                    }
                                    .foregroundColor(.white)
                                    .background(.blue)
                                    .frame(minWidth: 80, minHeight: 35)
                                    .cornerRadius(16)

                                    Spacer()

                                    if store.state.item.userId != store.packages.sessionService.userDetails.auth?.id {
                                        toggleFavoritesButton
                                    }
                                }
                            }
                            .padding(.horizontal, 8)

                            Spacer()
                        }

                        Divider()
                            .bold(true)
                            .background(.secondary)
                            .padding(.vertical)
                    }
                    .padding()
                }
                .onAppear {
                    if let iconData = store.state.item.icon, let image = UIImage(data: iconData) {
                        self.image = Image(uiImage: image)
                    }
                }
            }
            .edgesIgnoringSafeArea(.bottom)
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

    private var toggleFavoritesButton: some View {
        Button(action: {
            store.dispatch(store.state.item.isSaved ? .removeFromSaved : .addToSaved)
        }, label: {
            Image(systemName: store.state.item.isSaved ? "heart.fill" : "heart")
                .modifier(ButtonClearProgressViewModifier(progressStatus: store.state.viewProgress))
                .frame(width: 30, height: 30)
                .font(.title)
        })
    }
}


struct ItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ItemDetailView(store: DetailItemStore(
            state: DetailItemState(item: Item.mockItems.randomElement()!),
            dispatcher: feedDetailItemDispatcher,
            reducer: feedDetailItemReducer,
            packages: DetailItemPackages(),
            middlewares: [DetailItemStore.middlewareOperation]
        )
)
    }
}
