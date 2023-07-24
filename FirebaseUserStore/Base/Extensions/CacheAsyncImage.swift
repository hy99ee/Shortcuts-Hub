import SwiftUI

struct CacheAsyncImage<I, P, E>: View where I: View,
                                            P: View,
                                            E: View {
    private let url: URL
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> I?
    @ViewBuilder private var placeholder: () -> P
    @ViewBuilder private var errorView: () -> E

    init(
        url: URL,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        content: @escaping (AsyncImagePhase) -> I?,
        @ViewBuilder placeholder: @escaping () -> P,
        @ViewBuilder errorView: @escaping () -> E
    ){
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self.placeholder = placeholder
        self.errorView = errorView
    }
    
    var body: some View {
        if let image = ImageCache[url] {
            cachedImage(image)
        } else {
            AsyncImage(
                url: url,
                scale: scale,
                transaction: transaction
            ) {
                cacheAndRender(phase: $0)
            }
        }
    }

    @ViewBuilder private func cachedImage(_ image: Image) -> some View {
        if let content = content(.success(image)) {
            content
        } else {
            placeholder()
        }
    }

    private func cacheAndRender(phase: AsyncImagePhase) -> AnyView {
        switch phase {
        case .empty:
            return AnyView(placeholder())
        case .success(let image):
            ImageCache[url] = image
            return AnyView(content(phase))
        case .failure:
            return AnyView(errorView())
        @unknown default:
            return AnyView(placeholder())
        }
    }
}

extension CacheAsyncImage: Equatable {
    static func == (lhs: CacheAsyncImage<I, P, E>, rhs: CacheAsyncImage<I, P, E>) -> Bool {
        lhs.url == rhs.url
    }
}

fileprivate class ImageCache{
    static private var cache: [URL: Image] = [:]
    static subscript(url: URL) -> Image?{
        get {
            ImageCache.cache[url]
        }
        set {
            ImageCache.cache[url] = newValue
        }
    }
}
