import SwiftUI

struct CacheAsyncImage<I, P>: View where I: View, P: View {
    private let url: URL
    private let scale: CGFloat
    private let transaction: Transaction
    private let content: (AsyncImagePhase) -> I?
    @ViewBuilder private var placeholder: () -> P

    init(
        url: URL,
        scale: CGFloat = 1.0,
        transaction: Transaction = Transaction(),
        content: @escaping (AsyncImagePhase) -> I?,
        @ViewBuilder placeholder: @escaping () -> P
    ){
        self.url = url
        self.scale = scale
        self.transaction = transaction
        self.content = content
        self.placeholder = placeholder
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

    private func cacheAndRender(phase: AsyncImagePhase) -> some View {
        if case .success (let image) = phase {
            ImageCache[url] = image
        }
        return content(phase)
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
