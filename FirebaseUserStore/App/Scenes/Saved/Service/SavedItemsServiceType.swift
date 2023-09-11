import Foundation

protocol SavedItemsServiceType: ItemsServiceType, DetainedServiceType where DetainedRequestType == SavedDetainedRequest {}

enum SavedDetainedRequest: RequestWithRepeatDelay {
    case initSaved
    case updateSaved

    var repeatDelaySeconds: Double {
        switch self {
        case .initSaved:
            return 10
        case .updateSaved:
            return 5
        }
    }
}
