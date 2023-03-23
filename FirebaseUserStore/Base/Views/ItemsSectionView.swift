import SwiftUI

struct ItemsSectionView: View {
    @State var items: [Item]
    let title: String
    let subtitle: String?

    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    let pagingLimits = 16
    @State private var offsetX: CGFloat = 50
    
//    @State private var rowLimits = 16
    
    var body: some View {
        ScrollView {
            Button {
                
            } label: {
                sectionView
                    .padding(.vertical, 16)
                    .background(.gray.opacity(0.3))
                    .cornerRadius(16)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .onReceive(timer) { input in
            withAnimation(.linear) {
                offsetX = offsetX + 5.0
            }
        }
        .padding(.horizontal, 16)
    }

    private var sectionView: some View {
        VStack(alignment: .leading, spacing: 24.0) {
            VStack(spacing: 12.0) {
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
                VStack(alignment: .leading, spacing: 12.0) {
                    
                    LazyHStack(spacing: 12.0) {
                        ForEach(0..<items.count, id: \.self) { index in
                            ItemCellView(item: items[index], cellStyle: .row3)
                                .onAppear {
                                    if index >= items.count - 1 {
                                        items += items
                                    }
                                }
                        }
                    }
//
                    HStack(spacing: 6) {
                        Rectangle()
                            .fill(.clear)
                            .frame(width: 50,
                                   height: 100)

                        LazyHStack(spacing: 12.0) {
                            ForEach(1...items.count, id: \.self) { index in
                                ItemCellView(item: items[items.count - index], cellStyle: .row3)
                            }
                        }
                    }
                }
                .offset(x: -offsetX)
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
