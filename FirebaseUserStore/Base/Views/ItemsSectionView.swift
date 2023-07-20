import SwiftUI

class OffsetCounter: ObservableObject {
    @Published var offset: CGFloat = 50

    let maximumTime: CGFloat
    lazy var maximumTimer = Timer.scheduledTimer(withTimeInterval: maximumTime, repeats: true) { _ in
        self.offset = 50
    }
    lazy var timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
        self.offset += 5
    }

    init(max maximumTime: CGFloat = 20) {
        self.maximumTime = maximumTime
        timer.fire()
        maximumTimer.fire()
    }
}

struct ItemsSectionView: View {
    private let sectionId: String
    @State private var icons: [CacheAsyncImage<Image, Color, Color>]
    @State private var title: String
    @State private var subtitle: String?
    @State private var localOffsetX: CGFloat = Self.offserCounter.offset

    private let namespace: Namespace.ID

    private static let offserCounter = OffsetCounter()

    private var iconWidth: CGFloat = 120
    private var iconHeight: CGFloat = 180

    fileprivate init(section: IdsSection, namespace: Namespace.ID) {
        self.sectionId = section.id.uuidString
        self.title = section.title
        self.subtitle = section.subtitle
        self.icons = section.titleIcons.map {
            CacheAsyncImage(
                url: $0,
                content: { image in
                    guard let image = image.image else { return nil }
                    return image.resizable(resizingMode: .stretch)
                },
                placeholder: { Color.secondary },
                errorView: { Color.red }
            )
        }
        self.namespace = namespace
    }
    
    var body: some View {
        if icons.count <= 0 {
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .frame(width: 100, height: 100)
                .onTapGesture { }
        } else {
            sectionView
                .background(.gray.opacity(0.3))
        }
    }

    private var sectionView: some View {
        VStack(alignment: .leading, spacing: 8) {
            VStack(spacing: 6) {
                Text(title)
                    .font(.title3)
                    .foregroundColor(.gray)
                    .fontWeight(.bold)
                    .hLeading()
                    .matchedGeometryEffect(id: "title_\(sectionId)", in: namespace)
                
                if let subtitle {
                    Text(subtitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .hLeading()
                        .matchedGeometryEffect(id: "subtitle_\(sectionId)", in: namespace)
                }
            }
            .padding(.leading, 20)
            .padding(.top, 14)
            
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
                .matchedGeometryEffect(id: "section_\(sectionId)", in: namespace)
            }

            .onReceive(Self.offserCounter.$offset) { offset in
                withAnimation(.linear) {
                    localOffsetX = offset
                }
            }
            .disabled(true)
        }
    }
}

fileprivate extension View {
    // MARK: Horizontal Leading
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

extension ItemsSectionView {
    @ViewBuilder static func createSectionView(section: IdsSection, namespace: Namespace.ID) -> some View {
        if section.titleIcons.count > 1 {
            ItemsSectionView(section: section, namespace: namespace)
        } else if let url = section.titleIcons.first {
            CacheAsyncImage<Image, Color, Color>(
                url: url,
                content: { image in
                    guard let image = image.image else { return nil }
                    return image.resizable(resizingMode: .stretch)
                },
                placeholder: { Color.secondary },
                errorView: { Color.red }
            )
            .matchedGeometryEffect(id: "section_\(section.id)", in: namespace)
        } else {
            RoundedRectangle(cornerRadius: 20)
        }
    }
}
