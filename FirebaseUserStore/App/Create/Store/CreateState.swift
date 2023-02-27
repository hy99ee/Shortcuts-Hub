import SwiftUI
import Combine

struct CreateState: StateType {
    enum CreateErrorType: Error {
        case link
        case upload
        case auth
    }

    var user: Item?

    var error: CreateErrorType?

    var viewProgress = ProgressViewProvider()
    var buttonProgress = ProgressViewProvider()

    let processView: ProcessViewProvider

    init() {
        processView = ProcessViewProvider(viewProgress, buttonProgress)
    }

    func reinit() -> Self {
        CreateState()
    }
}
