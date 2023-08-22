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

        case `default`(status: ContentStatus? = nil)
        case search(status: ContentStatus? = nil)
    }
    case content(type: ContentType)
    case empty(type: ContentType)
    case loading
}

protocol FeedContentState {
    var content: FeedContent { get set }
}

extension FeedContentState {
    func tryTakeItemsFrom() {
        
    }
}


