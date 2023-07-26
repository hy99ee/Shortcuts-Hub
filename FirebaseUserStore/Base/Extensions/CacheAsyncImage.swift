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

    @ViewBuilder private func cacheAndRender(phase: AsyncImagePhase) -> some View {
        switch phase {
        case .empty:
            placeholder()
        case .success(let image):
            successCacheAndRender(image: image)
        case .failure:
            errorView()
        @unknown default:
            placeholder()
        }
    }

    private func successCacheAndRender(image: Image) -> some View {
        ImageCache[url] = image
        return content(.success(image))
    }
}

extension CacheAsyncImage: Identifiable {
    var id: URL {
        url
    }
}

extension CacheAsyncImage: Equatable {
    static func == (lhs: CacheAsyncImage<I, P, E>, rhs: CacheAsyncImage<I, P, E>) -> Bool {
        lhs.url == rhs.url
    }
}

extension CacheAsyncImage: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(url)
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
