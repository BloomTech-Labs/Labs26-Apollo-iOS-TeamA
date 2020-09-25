//
//  String+Validate.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/3/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

extension String {
    /// Remove letters and lowercase a string
    mutating func sanitizeNumberString() {
        // This will make an array split by any non number
        let wordArray = split { !$0.isNumber }
        // Joins the above into a single string and makes it lowercased for 1:1 comparisons (lower to lower)
        self = wordArray.joined()
            .lowercased()
    }

    /// Determine if a given string is a valid phone number
    func isValidPhone() -> Bool {
        var string = self
        string.sanitizeNumberString() // this might remove the `+` but that's ok since we're normally only interested in the numbers anyway
        let phoneRegex = "^[0-9+]{0,1}+[0-9]{5,16}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: string)
    }

    /// Determine if a given string is a valid email address
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: self)
    }
}
