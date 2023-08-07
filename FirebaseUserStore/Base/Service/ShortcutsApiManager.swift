import UIKit

final class ShortcutsApiManager {
    func call(_ destination: ApiDestinationTarget) {
        UIApplication.shared.open(destination.makeURL(), options: [:], completionHandler: nil)
    }

    enum ApiDestinationTarget {
        case run(name: String)
//        case search(name: String)
//        case `import`(url: String, name: String)

        func makeURL() -> URL {
            URL(string: String(Self.baseURL + self.path).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")!
        }

        private static let baseURL = "shortcuts://"

        private var path: String {
            switch self {
            case let .run(name): return "run-shortcut?name=\(name)"
//            case let .search(name): return "search?query=[\(name)]"
//            case let .`import`(url, name): return "import-shortcut/?url=[\(url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)]&name=[\(name)]&silent=[true]"
            }
        }
    }
}
