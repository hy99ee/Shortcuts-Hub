import Foundation

struct LandmarkDispatcher: DispatcherType {
    typealias MutationType = LandmarkMutation
    var commit: (MutationType) -> Void
    
    init(commit: @escaping (MutationType) -> Void) {
        self.commit = commit
    }
    
    func dispatch(action: LandmarkAction) {
        //    switch action {
        //    case .FetchParkDescription(let landmark):
        //      FetchParkDescription(landmark: landmark)
        //    }
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
