//
//  User.swift
//  FirebaseUserStore
//
//  Created by hy99ee on 15.03.2023.
//

import Foundation
enum DatabaseUserKeys: String {
    case firstName
    case lastName
    case phone
    case savedIds
}

struct DatabaseUser {
    let firstName: String
    let lastName: String
    let phone: String
    let savedIds: [String]

    var databaseFormat: [String: Any] {
        [
            DatabaseUserKeys.firstName.rawValue: self.firstName,
            DatabaseUserKeys.lastName.rawValue: self.lastName,
            DatabaseUserKeys.phone.rawValue: self.phone,
            DatabaseUserKeys.savedIds.rawValue: self.savedIds
        ]
    }
}
