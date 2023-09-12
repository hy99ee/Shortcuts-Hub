import Foundation

protocol RequestWithRepeatDelay: Hashable {
    var repeatDelaySeconds: Double { get }
}

protocol DetainedServiceType: AnyObject {
    associatedtype DetainedRequestType: RequestWithRepeatDelay
    var detainedRequests: [DetainedRequestType : DispatchTime] { get set }
}

extension DetainedServiceType {
    func isTimeTo(request: DetainedRequestType) -> Bool {
        guard let requestCallTime = detainedRequests[request] else {
            detainedRequests[request] = .now()
            return true
        }
        let ableTime = requestCallTime + request.repeatDelaySeconds
        let currentTime = DispatchTime.now()
        let distance = currentTime.distance(to: ableTime)

        if case DispatchTimeInterval.nanoseconds(let value) = distance {
            if value <= 0 {
                detainedRequests[request] = .now()
                return true
            } else {
                return false
            }
        } else {
            return true
        }
    }

}
