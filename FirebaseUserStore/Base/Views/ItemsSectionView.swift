import SwiftUI

class OffsetCounter: ObservableObject {
    @Published var offset: CGFloat = 50

    lazy var timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in self.offset += 5 }

    init() { timer.fire() }
}


struct ItemsSectionView: View {
    @State private var icons: [CacheAsyncImage<Image, Color>]
    @State private var title: String
    @State private var subtitle: String?
    @State private var localOffsetX: CGFloat = Self.offserCounter.offset
    @State private var isDetail: Bool

    private static let offserCounter = OffsetCounter()

    let pagingLimits = 16
    
    init(section: IdsSection, isDetail: Bool = false) {
        self.title = section.title
        self.subtitle = section.subtitle
        self.icons = section.titleIcons.map {
            CacheAsyncImage(
                url: $0,
                content: { image in
                    guard let image = image.image else { return nil }
                    return image.resizable(resizingMode: .stretch)
                },
                placeholder: { Color.red }
            )
        }
        self.isDetail = isDetail
    }
    
    var body: some View {
        if icons.count <= 0 {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .frame(width: 100, height: 100)
                .onTapGesture { }
        } else {
            sectionView
                .padding(.vertical, 8)
                .background(.gray.opacity(0.3))
                .cornerRadius(8)
        }
    }

    private var sectionView: some View {
        VStack(alignment: .leading, spacing: 14.0) {
            VStack(spacing: 10.0) {
                Text(title)
                    .font(.title3)
                    .foregroundColor(.gray)
                    .fontWeight(.bold)
                    .hLeading()
                
                if let subtitle {
                    Text(subtitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .hLeading()
                }
            }
            .padding(.leading, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 6.0) {
                    LazyHStack(spacing: 6.0) {
                        ForEach(0..<icons.count, id: \.self) { index in
                            icons[index]
                                .frame(width: iconWidth, height: iconHeight)
                                .cornerRadius(5)
                        }
                    }

                    HStack(spacing: 6) {
                        Rectangle()
                            .fill(.clear)
                            .frame(width: 50)
                        
                        LazyHStack(spacing: 6.0) {
                            ForEach(1...icons.count, id: \.self) { index in
                                icons[icons.count - index]
                                    .frame(width: iconWidth, height: iconHeight)
                                    .cornerRadius(5)
                            }
                        }
                    }
                }
                .offset(x: -localOffsetX)
            }
            .onReceive(Self.offserCounter.$offset) { offset in
                withAnimation(.linear) {
                    localOffsetX = offset
                }
            }
            .disabled(true)
        }
    }
    private var iconWidth: CGFloat { isDetail ? 120 : 120 }
    private var iconHeight: CGFloat { isDetail ? 180 : 180 }
}

fileprivate extension View {
    // MARK: Horizontal Leading
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
         configuration.label
             .scaleEffect(configuration.isPressed ? 0.95 : 1)
             .animation(.linear(duration: 0.2), value: configuration.isPressed)
             .brightness(configuration.isPressed ? -0.05 : 0)
     }
}

extension ButtonStyle where Self == ScaleButtonStyle {
    static var scale: ScaleButtonStyle {
        ScaleButtonStyle()
    }
}

//struct DownloadableImage: View {
//    let url: URL
//    @State private var image: Image?
//
//    var body: some View {
//
//    }
//
//    // MARK: Image request
//    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
//        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
//    }
//
//    func downloadImage(from url: URL) -> Image? {
//        getData(from: url) { data, response, error in
//            guard let data = data, error == nil else { return }
//
//            if let image = UIImage(data: data) {
//                return Image(uiImage: image)
//            }
//        }
//    }
//}
