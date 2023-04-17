import Foundation

enum FeedDetailSectionCredentialsField: CaseIterable {
    case email
    case phone
    case password
    case conformPassword
    case firstName
    case lastName
}

struct FeedDetailSectionCredentials {
    var email = ""
    var phone = ""
    var password = ""
    var conformPassword = ""
    var firstName = ""
    var lastName = ""
}
