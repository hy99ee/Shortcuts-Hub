import Foundation
import Combine

struct FeedDispatcher: DispatcherType {
    typealias MutationType = FeedMutation
    
    func dispatch(action: FeedAction) -> AnyPublisher<MutationType, Never> {
        switch action {
        case .startAction:
            return Just<MutationType>(.startMutation).eraseToAnyPublisher()
        }
    }

//  func FetchParkDescription() {
//    guard let escapedName = landmark.park.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
//    let url = "https://en.wikipedia.org/w/api.php?action=query&prop=extracts&format=xml&exintro=&explaintext&titles=" + escapedName
//
//    Alamofire.request(url).responseString { response in
//      guard let responseXML = response.result.value else { return }
//      let xml = SWXMLHash.parse(responseXML)
//      guard let description = xml["api"]["query"]["pages"]["page"]["extract"].element?.text else { return }
//
//      self.commit(LandmarkMutation.SetParkDescription(landmark.id, description))
//    }
//  }
}
