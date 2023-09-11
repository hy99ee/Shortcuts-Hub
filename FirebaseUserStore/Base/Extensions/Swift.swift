import Foundation

public extension Equatable {
  func equals(_ any: some Any) -> Bool {
    self == any as? Self
  }
}
