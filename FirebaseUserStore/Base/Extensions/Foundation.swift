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
        self.count >= 8 && !self.localizedStandardContains(" ")
    }

    var isEqualDoublePassword: Bool {
        let password = self.components(separatedBy: " ")
        return password.count == 2 && password[0] == password[1]
    }

    func combine(_ string: String, with separator: String = " ") -> Self {
        self + separator + string
    }

    private func validate(regexp expession: String) -> Bool {
        self.range(
            of: expession,
            options: .regularExpression
        ) != nil
    }
}
