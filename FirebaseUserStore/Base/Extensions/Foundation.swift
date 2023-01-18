import Foundation

extension String {
    var isEmail: Bool {
        validate(regexp: #"^\S+@\S+\.\S+$"#)
    }

    var isPhone: Bool {
        validate(regexp: #"^\(?\d{3}\)?[ -]?\d{3}[ -]?\d{4}$"#)
    }

    var isUsername: Bool {
        validate(regexp: #"^[a-zA-Z-]"#)
    }

    var isPassword: Bool {
        self.count >= 8
    }

    private func validate(regexp expession: String) -> Bool {
        self.range(
            of: expession,
            options: .regularExpression
        ) != nil
    }
}
