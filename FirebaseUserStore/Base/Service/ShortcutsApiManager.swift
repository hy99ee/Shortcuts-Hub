import UIKit

protocol ShortcutsApiManagerType {
    func call()
}

final class ShortcutsApiManager {
    func call(_ destination: ApiDestinationTarget) {
        UIApplication.shared.open(destination.makeURL(), options: [:], completionHandler: nil)
    }

    enum ApiDestinationTarget {
        case run(name: String)
        case `import`(url: URL, name: String)

        func makeURL() -> URL {
            URL(string: String(Self.baseURL + self.path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")!
        }

        private static let baseURL = "shortcuts://"

        private var path: String {
            switch self {
            case let .run(name): return "run-shortcut?name=\(name)"
            case let .`import`(url, name): return ""
            }
        }
    }
}
