import Foundation
import Combine

struct FeedDispatcher: DispatcherType {
    typealias MutationType = FeedMutation
    typealias ServiceEnvironment = FeedEnvironment
    
    func dispatch(_ action: FeedAction, environment: ServiceEnvironment) -> AnyPublisher<MutationType, Never> {
        switch action {
        case .startAction:
            return Just(.startMutation).eraseToAnyPublisher()
        }
    }

//    private var fetchPublisher: AnyPublisher<[Item], Never> {
//        service.fetchDishesByUserRequest()
//            .catch { error -> AnyPublisher<[Item], Never> in
//                print(error.localizedDescription)
//                return Just([]).eraseToAnyPublisher()
//            }
//            .eraseToAnyPublisher()
//    }

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
