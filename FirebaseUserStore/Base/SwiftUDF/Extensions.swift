import SwiftUDF

protocol EnvironmentPackagesWithSessionWithSession: EnvironmentPackages {
    var sessionService: SessionService { get }
}

extension EnvironmentPackagesWithSessionWithSession {
    var sessionService: SessionService { SessionService.shared }
}

enum FeedContent: Equatable {
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

protocol FeedContentState {
    var content: FeedContent { get set }
}

extension FeedContentState {
    func tryTakeItemsFrom() {
        
    }
}


