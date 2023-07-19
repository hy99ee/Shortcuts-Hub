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
    @State private var icons: [CacheAsyncImage<Image, Color, Color>]
    @State private var title: String
    @State private var subtitle: String?
    @State private var localOffsetX: CGFloat = Self.offserCounter.offset

    private static let offserCounter = OffsetCounter()

    private var iconWidth: CGFloat = 120
    private var iconHeight: CGFloat = 180

    fileprivate init(section: IdsSection) {
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
                
                if let subtitle {
                    Text(subtitle)
                        .font(.title)
                        .fontWeight(.bold)
                        .hLeading()
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
    @ViewBuilder static func createSectionView(section: IdsSection) -> some View {
        if section.titleIcons.count > 1 {
            ItemsSectionView(section: section)
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
        } else {
            RoundedRectangle(cornerRadius: 20)
        }
    }
}


//extension ItemsSectionView {
//    @ViewBuilder static func createSectionView(section: IdsSection) -> some View {
//        if section.titleIcons.count > 1 {
//            createMultipleSectionView(section: section)
//        } else {
//            createSingleSectionView(section: section)
//        }
//    }
//
//    static func createMultipleSectionView(section: IdsSection) -> ItemsSectionView {
//        if let section = cacheManager.cached[section.id] {
//            return section
//        } else {
//            let view = ItemsSectionView(section: section)
//            cacheManager.cached.updateValue(view, forKey: section.id)
//            return view
//        }
//    }
//
//    static func createSingleSectionView(section: IdsSection) -> CacheAsyncImage<Image, Color, Color> {
//        CacheAsyncImage<Image, Color, Color>(
//            url: section.titleIcons.first!,
//            content: { image in
//                guard let image = image.image else { return nil }
//                return image.resizable(resizingMode: .stretch)
//            },
//            placeholder: { Color.secondary },
//            errorView: { Color.red }
//        )
//    }
//}
