//
//  StringExtesions.swift
//  FirebaseUserStore
//
//  Created by hy99ee on 26.12.2022.
//

import Foundation

extension String {
    var capitalizedSentence: String {
        let firstLetter = self.prefix(1).capitalized
        let remainingLetters = self.dropFirst().lowercased()
        return firstLetter + remainingLetters
    }
}
