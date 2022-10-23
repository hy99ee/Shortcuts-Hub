import SwiftUI
import Combine

struct FeedState: StateType {
    var items: [Item] = [Item(id: UUID(), userId: "ID", title: "Need to refresh", description: "Desc", source: "Source")]

//    func itemBy(id: Int) -> String {
//        items[id]
//    }
//  func landmark(withId id: Int) -> Landmark {
//    return landmarks.first(where: { $0.id == id })!
//  }
//
//  func landmarkIndex(withId id: Int) -> Int {
//    return landmarks.firstIndex(where: { $0.id == id })!
//  }
//
//  var landmarkCategories: [String: [Landmark]] {
//    .init(
//      grouping: landmarks,
//      by: { $0.category.rawValue }
//    )
//  }
//
//  var featuredLandmarks: [Landmark] {
//    landmarks.filter { $0.isFeatured }
//  }
}
