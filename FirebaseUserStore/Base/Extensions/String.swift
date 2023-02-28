import Foundation

extension String {
    var isEmail: Bool {
        validate(regexp: #"^\S+@\S+\.\S+$"#)
    }

    var isPhone: Bool {
        validate(regexp: #"^[+]?\d{1}\(?\d{3}\)?[-]?\d{3}[-]?\d{2}[-]?\d{2}$"#)
    }

    var isUsername: Bool {
        validate(regexp: #"^[a-zA-Z-]"#)
    }

    var isPasswordMinCount: Bool {
        self.count >= 8
    }

    var isPasswordMaxCount: Bool {
        self.count < 16
    }

    var passwordValidationMessage: String? {
        if !self.isPasswordMinCount {
            return "The password must be longer than 8 characters"
        } else if !self.isPasswordMaxCount {
            return "The password must be shorter than 16 characters"
        } else if self.localizedStandardContains(" ") {
            return "The password must be without a space"
        } else {
            return nil
        }
    }

    var conformPasswordValidationMessage: String? {
        let password = self.components(separatedBy: " ")
        return (password.count == 2 && password[0] == password[1]) ? nil : "Passwords are not equal"
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
    
    func generateStringSequence() -> [String] {
        var sequences: [String] = []
        for i in 1...self.suffix(5).count {
            sequences.append(String(self.prefix(i)))
        }
        return sequences
    }
    
}
