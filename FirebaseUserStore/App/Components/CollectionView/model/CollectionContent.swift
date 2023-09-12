import Foundation

enum CollectionContent: Equatable {
    enum ContentType: Equatable {
        enum ContentStatus: Equatable {
            case preload(loaders: [LoaderItem])
            case loaded(items: [Item])
        }

        case `default`(status: ContentStatus?)
        case search(status: ContentStatus?)
    }
    case content(type: ContentType)
    case empty(type: ContentType)
    case error(type: ContentType)
    case loading
}
