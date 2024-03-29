import SwiftUI

class OffsetCounter: ObservableObject {
    @Published var offset: CGFloat = 50

    let maximumTime: CGFloat
    lazy var maximumTimer = Timer.scheduledTimer(withTimeInterval: maximumTime, repeats: true) { _ in
        self.offset = 50
    }
    lazy var timer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { _ in
        self.offset += 2.5
    }

    init(max maximumTime: CGFloat = 20) {
        self.maximumTime = maximumTime
        timer.fire()
        maximumTimer.fire()
    }
}

struct ItemsSectionView: View {
    @State private var icons: [EquatableView<Image>]
    @State private var title: String
    @State private var subtitle: String?
    @State private var localOffsetX: CGFloat = Self.offserCounter.offset

    @State private var navigationHeader: CGFloat = 0

    @EnvironmentObject var namespaceWrapper: NamespaceWrapper

    @State private var isDetail: Bool
    private let sectionId: String

    private static let offserCounter = OffsetCounter()

    private var iconWidth: CGFloat = 100
    private var iconHeight: CGFloat = 100

    init(section: IdsSection, isDetail: Bool = false) {
        self.sectionId = section.id.uuidString
        self.title = section.title.first != nil ? (String(section.title.prefix(1) + section.title.dropFirst())) : ""
        self.subtitle = section.subtitle.first != nil ? (String(section.subtitle.prefix(1) + section.subtitle.dropFirst())) : ""
        self.icons = section.titleIcons.map {
            Image(uiImage: .init(data: $0) ?? .init()).equatable()
        }
        self.isDetail = isDetail
    }
    
    var body: some View {
        VStack {
            if isDetail {
                backgroundView
                    .padding(.vertical, navigationHeader == 0 ? -30 : -10)
                    .padding(.horizontal, navigationHeader == 0 ? -10 : 0)
                    .transition(.move(edge: .bottom))
                    .frame(minHeight: navigationHeader, maxHeight: navigationHeader)
                    .scaleEffect(navigationHeader == 0 ? 0.95 : 1)
                    .onAppear {
                        withAnimation(.easeOut(duration: 0.45)) {
                            navigationHeader = Utilities.shared.safeAreaInsets?.top ?? 0
                        }
                    }
            }
            sectionView
        }
        .cornerRadius(navigationHeader == 0 && isDetail ? 30 : 0)
        .frame(height: 320)
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


            if icons.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 6.0) {
                        LazyHStack(spacing: 6.0) {
                            ForEach(0..<icons.count, id: \.self) { index in
                                icons[index]
                                    .content
                                    .equatable()
                                    .frame(width: iconWidth, height: iconHeight)
                                    .cornerRadius(10)
                            }
                        }

                        HStack(spacing: 6) {
                            Rectangle()
                                .fill(.clear)
                                .frame(width: 50)

                            LazyHStack(spacing: 6.0) {
                                ForEach(1...icons.count, id: \.self) { index in
                                    icons[icons.count - index]
                                        .content
                                        .equatable()
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

            } else if icons.count == 1 {
                icons.first
                    .padding(.vertical)
            } else if icons.count == 0 {
                Color.secondary
            } else {
                RoundedRectangle(cornerRadius: 20)
            }
        }
        .background {
            backgroundView
        }
    }

    var backgroundView: some View {
        ZStack {
            BlurView(style: .systemThinMaterial)
            Color.gray.opacity(0.3)
        }
    }
}

extension ItemsSectionView: Identifiable {
    var id: String {
        sectionId
    }
}

extension ItemsSectionView: Equatable {
    static func == (lhs: ItemsSectionView, rhs: ItemsSectionView) -> Bool {
        lhs.sectionId == rhs.sectionId
    }
}

extension ItemsSectionView: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(sectionId)
    }
}



extension View {
    // MARK: Horizontal Leading
    func hLeading() -> some View {
        self
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
